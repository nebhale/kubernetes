package init

import (
	"bytes"
	"crypto/sha256"
	"fmt"
	"io"
	"net/http"

	apiextV1 "k8s.io/apiextensions-apiserver/pkg/apis/apiextensions/v1"
	"k8s.io/cli-runtime/pkg/genericclioptions"
	"k8s.io/cli-runtime/pkg/resource"
	"k8s.io/client-go/kubernetes/scheme"
	apiregV1 "k8s.io/kube-aggregator/pkg/apis/apiregistration/v1"
)

type Init struct {
	KappController      Metadata
	SecretGenController Metadata
	DryRun              bool
}

type Metadata struct {
	Version string
	SHA256  string
}

func (i *Init) Run(flags *genericclioptions.ConfigFlags) error {
	url := fmt.Sprintf("https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v%s/release.yml", i.KappController.Version)
	kapp, err := get(url, i.KappController.SHA256)
	if err != nil {
		return fmt.Errorf("unable to download kapp-controller: %w", err)
	}

	err = builder(flags).
		Stream(bytes.NewReader(kapp), url).
		Do().
		Visit(func(i *resource.Info, err error) error {
			fmt.Println(i.Name)
			return nil
		})
	if err != nil {
		return fmt.Errorf("unable to apply kapp-controller: %w", err)
	}

	// url = fmt.Sprintf("https://github.com/vmware-tanzu/carvel-secretgen-controller/releases/download/v%s/release.yml", i.SecretGenController.Version)
	// secretGen, err := get(url, i.SecretGenController.SHA256)
	// if err != nil {
	// 	return fmt.Errorf("unable to download secretgen-controller: %w", err)
	// }

	// fmt.Println(string(kapp))
	// fmt.Println(string(secretGen))
	return nil
}

func builder(flags *genericclioptions.ConfigFlags) *resource.Builder {
	namespace := ""
	if flags.Namespace != nil {
		namespace = *flags.Namespace
	}

	_ = apiextV1.AddToScheme(scheme.Scheme)
	_ = apiregV1.AddToScheme(scheme.Scheme)

	return resource.NewBuilder(flags).
		WithScheme(scheme.Scheme, scheme.Scheme.PrioritizedVersionsAllGroups()...).
		NamespaceParam(namespace).
		DefaultNamespace().
		ContinueOnError()
}

func get(url string, expected string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode >= http.StatusBadRequest {
		return nil, fmt.Errorf(http.StatusText(resp.StatusCode))
	}

	body := HashReader{
		Reader: resp.Body,
		Hash:   sha256.New(),
	}

	bytes, err := io.ReadAll(body)
	if err != nil {
		return nil, err
	}

	if expected != body.Sum() {
		return nil, fmt.Errorf("hash does not match. expected %s, actual %s", expected, body.Sum())
	}

	return bytes, nil
}
