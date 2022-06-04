package root

import (
	"github.com/spf13/cobra"
	"k8s.io/cli-runtime/pkg/genericclioptions"
)

func NewCommand(flags *genericclioptions.ConfigFlags) *cobra.Command {
	cmd := &cobra.Command{
		Use:   "tanzu",
		Short: "Tanzu is a Kubernetes-based application platform",
		Long:  "A lightweight application-aware platform for application built on the finest open-source projects in the Kubernetes ecosystem.",
	}

	flags.AddFlags(cmd.PersistentFlags())

	return cmd
}
