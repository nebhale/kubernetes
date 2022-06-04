package init

import (
	"github.com/spf13/cobra"
	"k8s.io/cli-runtime/pkg/genericclioptions"
)

var defaults = map[string]map[string]string{
	"kapp-controller": {
		"version": "0.37.0",
		"sha256":  "52567f535ff6154c5b94925648cbc4ffcc307bf1e4e5609619ed779a37f49b26",
	},
	"secretgen-controller": {
		"version": "0.8.0",
		"sha256":  "9c786559171dec5799f40031e846a58646b0d29e4c1beccfa5e07f2c9dbdae1e",
	},
}

func NewCommand(flags *genericclioptions.ConfigFlags) *cobra.Command {
	var init = &Init{}

	cmd := &cobra.Command{
		Use:          "init",
		Short:        "Initialize a cluster for Tanzu",
		Long:         `Add the essential components required to bootstrap Tanzu`,
		SilenceUsage: true,
		RunE: func(cmd *cobra.Command, args []string) error {
			return init.Run(flags)
		},
	}

	cmd.Flags().StringVar(&init.KappController.Version, "kapp-controller-version", defaults["kapp-controller"]["version"], "The kapp-controller release version")
	cmd.Flags().StringVar(&init.KappController.SHA256, "kapp-controller-sha256", defaults["kapp-controller"]["sha256"], "The kapp-controller release sha256")
	cmd.Flags().StringVar(&init.SecretGenController.Version, "secretgen-controller-version", defaults["secretgen-controller"]["version"], "The secretgen-controller release version")
	cmd.Flags().StringVar(&init.SecretGenController.SHA256, "secretgen-controller-sha256", defaults["secretgen-controller"]["sha256"], "The secretgen-controller release sha256")
	cmd.Flags().BoolVar(&init.DryRun, "dry-run", false, "Print resources without applying them to a cluster")

	return cmd
}
