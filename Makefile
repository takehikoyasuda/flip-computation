# Build the package documentation and leave it at a fixed path, so that a
# browser tab opened on it once can be reloaded after every edit.
DOCDIR := doc-build
DOCINDEX := $(DOCDIR)/share/doc/Macaulay2/FlipComputation/html/index.html

# No RerunExamples and no RemakeAllDocumentation on purpose: M2 hashes each
# example block and reruns only the ones whose input changed, so an edit to the
# prose alone reruns none of them.  `make docs-all` is the build that assumes
# nothing is cached.
#
# IgnoreExampleErrors is off so that an example which stops working fails the
# build here rather than being written to a log nobody reads.  Examples are the
# one part of the documentation that cannot be wrong quietly.
M2DOC = M2 --no-readline --no-debug -q -e

# Built up in pieces, and each recipe passes one unbroken line to the shell.
# A backslash-newline inside the single-quoted M2 expression is not portable:
# GNU make 3.81, as shipped on macOS, joins those lines before handing the
# recipe to the shell, while make 4.x leaves the backslash in place, where
# single quotes stop the shell from removing it and M2 stops with
# "syntax error at '\'".
INSTALL_ARGS = FileName => "FlipComputation.m2", InstallPrefix => "$(CURDIR)/$(DOCDIR)/", IgnoreExampleErrors => false, MakeInfo => false
REMAKE_ARGS = RerunExamples => true, RemakeAllDocumentation => true

docs:
	$(M2DOC) 'installPackage("FlipComputation", $(INSTALL_ARGS)); exit 0' < /dev/null
	@echo
	@echo "file://$(CURDIR)/$(DOCINDEX)"

# Everything from scratch: every example rerun, every page regenerated.  Use it
# after changing the code the examples call, or before a release.
docs-all:
	rm -rf $(DOCDIR)
	$(M2DOC) 'installPackage("FlipComputation", $(INSTALL_ARGS), $(REMAKE_ARGS)); exit 0' < /dev/null
	@echo
	@echo "file://$(CURDIR)/$(DOCINDEX)"

test:
	M2 --script tests/run-tests.m2

# Separate from clean, because $(DOCDIR) holds the cached example output that
# makes `make docs` fast.  Removing it is a deliberate act, not housekeeping.
docs-clean:
	rm -rf $(DOCDIR)

.PHONY: docs docs-all docs-clean test
