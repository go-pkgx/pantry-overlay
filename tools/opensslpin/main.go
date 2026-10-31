// Command opensslpin resolves constraints for a project against the real
// registry, per platform, with bottle.PickVersionFor (the platform-checked
// resolver, not the platform-blind tag listing bottle.VersionsFor).
//
//	opensslpin --project openssl.org '^3' '^3.5' '~3.5' '*'
package main

import (
	"fmt"
	"os"

	"github.com/go-pkgx/bottle"
	"github.com/spf13/cobra"
)

var osExit = os.Exit

var platforms = [][2]string{
	{"darwin", "aarch64"}, {"darwin", "x86-64"},
	{"linux", "x86-64"}, {"linux", "aarch64"},
}

// Resolve returns "version" or "ERR: ..." for each platform, in platforms order.
func Resolve(project, constraint string) []string {
	out := make([]string, 0, len(platforms))
	for _, p := range platforms {
		v, err := bottle.PickVersionFor(project, constraint, p[0], p[1])
		if err != nil {
			out = append(out, fmt.Sprintf("%s/%s: ERR %v", p[0], p[1], err))
			continue
		}
		out = append(out, fmt.Sprintf("%s/%s: %s", p[0], p[1], v.Raw))
	}
	return out
}

// RootCmd builds the command.
func RootCmd() *cobra.Command {
	var project string
	cmd := &cobra.Command{
		Use:           "opensslpin [flags] CONSTRAINT...",
		Args:          cobra.MinimumNArgs(1),
		SilenceUsage:  true,
		RunE: func(cmd *cobra.Command, args []string) error {
			w := cmd.OutOrStdout()
			for _, c := range args {
				fmt.Fprintf(w, "%s %s\n", project, c)
				for _, l := range Resolve(project, c) {
					fmt.Fprintf(w, "  %s\n", l)
				}
			}
			return nil
		},
	}
	cmd.Flags().StringVar(&project, "project", "openssl.org", "registry project")
	return cmd
}

func main() {
	if err := RootCmd().Execute(); err != nil {
		osExit(1)
	}
}
