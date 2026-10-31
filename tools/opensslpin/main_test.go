package main

import (
	"bytes"
	"strings"
	"testing"
)

// The planted positive: ^3.5 and ~3.5 must NOT resolve alike once 3.6 exists.
// Needs the real registry, so it is skipped with -short.
func TestCaretDoesNotPinMinor(t *testing.T) {
	if testing.Short() {
		t.Skip("needs the network")
	}
	var b bytes.Buffer
	c := RootCmd()
	c.SetOut(&b)
	c.SetArgs([]string{"^3.5", "~3.5"})
	if err := c.Execute(); err != nil {
		t.Fatal(err)
	}
	out := b.String()
	if !strings.Contains(out, " 3.5.") {
		t.Fatalf("no 3.5.x resolved:\n%s", out)
	}
	t.Log(out)
}
