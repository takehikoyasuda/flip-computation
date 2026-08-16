# Build the technical note.
#
# SOURCE_DATE_EPOCH and FORCE_SOURCE_DATE stop pdflatex from stamping the build
# time into the file, so identical input gives a byte-identical PDF.  Without
# them every rebuild produces a different file and shows up as a git change even
# when nothing was edited -- and since a PDF is already compressed, git cannot
# delta it, so each of those non-changes would cost a full copy in the history.
#
# Bump the date when the note is substantively revised; it is what the PDF
# reports as its creation date.
SOURCE_DATE_EPOCH := 1785542400		# 2026-08-01

PDFLATEX = SOURCE_DATE_EPOCH=$(SOURCE_DATE_EPOCH) FORCE_SOURCE_DATE=1 \
	   pdflatex -interaction=nonstopmode -halt-on-error

# Twice: the first pass writes the cross-references, the second resolves them.
IMPLEMENTATION.pdf: IMPLEMENTATION.tex
	$(PDFLATEX) $<
	$(PDFLATEX) $<

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

clean:
	rm -f IMPLEMENTATION.aux IMPLEMENTATION.log IMPLEMENTATION.out \
	      IMPLEMENTATION.toc

# Separate from clean, because $(DOCDIR) holds the cached example output that
# makes `make docs` fast.  Removing it is a deliberate act, not housekeeping.
docs-clean:
	rm -rf $(DOCDIR)

.PHONY: clean docs docs-all docs-clean test
