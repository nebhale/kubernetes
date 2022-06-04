package main

import (
	"fmt"
	"os"

	tinit "github.com/nebhale/kubernetes/pkg/init"
	"github.com/nebhale/kubernetes/pkg/root"
	"k8s.io/cli-runtime/pkg/genericclioptions"
)

func main() {
	flags := genericclioptions.NewConfigFlags(true)

	root := root.NewCommand(flags)

	init := tinit.NewCommand(flags)
	root.AddCommand(init)

	if err := root.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
