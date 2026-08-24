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

docs:
	$(M2DOC) 'installPackage("FlipComputation", \
	    FileName => "FlipComputation.m2", \
	    InstallPrefix => "$(CURDIR)/$(DOCDIR)/", \
	    IgnoreExampleErrors => false, \
	    MakeInfo => false); exit 0' < /dev/null
	@echo
	@echo "file://$(CURDIR)/$(DOCINDEX)"

# Everything from scratch: every example rerun, every page regenerated.  Use it
# after changing the code the examples call, or before a release.
docs-all:
	rm -rf $(DOCDIR)
	$(M2DOC) 'installPackage("FlipComputation", \
	    FileName => "FlipComputation.m2", \
	    InstallPrefix => "$(CURDIR)/$(DOCDIR)/", \
	    RerunExamples => true, RemakeAllDocumentation => true, \
	    IgnoreExampleErrors => false, \
	    MakeInfo => false); exit 0' < /dev/null
	@echo
	@echo "file://$(CURDIR)/$(DOCINDEX)"

test:
	M2 --script tests/run-tests.m2

# Separate from clean, because $(DOCDIR) holds the cached example output that
# makes `make docs` fast.  Removing it is a deliberate act, not housekeeping.
docs-clean:
	rm -rf $(DOCDIR)

.PHONY: docs docs-all docs-clean test
