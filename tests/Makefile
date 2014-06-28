#
# Makefile to run all tests
# Copied from vim source
#

VIMPROG=vim

SCRIPTS = $(patsubst %.ok,%.out,$(wildcard *.ok))

.SUFFIXES: .in .out

nongui:	nolog $(SCRIPTS) report

report:
	@echo
	@echo 'Test results:'
	@/bin/sh -c "if test -f test.log; \
		then cat test.log; echo TEST FAILURE; exit 1; \
		else echo ALL OK; \
		fi"

clean:
	-rm -rf *.out *.failed *.rej *.orig test.log tiny.vim small.vim mbyte.vim mzscheme.vim test.ok X* valgrind.* viminfo

test1.out: test1.in
	-rm -f $*.failed tiny.vim small.vim mbyte.vim mzscheme.vim test.ok X* viminfo
	$(VALGRIND) $(VIMPROG) -u unix.vim -U NONE --noplugin -s dotest.in $*.in
	@/bin/sh -c "if diff -u test.out $*.ok; \
		then mv -f test.out $*.out; \
		else echo; \
		echo test1 FAILED - Something basic is wrong; \
		echo; exit 1; fi"
	-rm -rf X* viminfo

.in.out:
	-rm -rf $*.failed test.ok test.out X* viminfo
	cp $*.ok test.ok
	$(VIMPROG) -u unix.vim -U NONE --noplugin -s dotest.in -c "set tags=./$*.fixtures/tags" $*.in
	@/bin/sh -c "if test -f test.out; then\
		  if diff -u test.out $*.ok; \
		  then mv -f test.out $*.out; \
		  else echo $* FAILED >>test.log; mv -f test.out $*.failed; \
		  fi \
		else echo $* NO OUTPUT >>test.log; \
		fi"
	-rm -rf X* test.ok viminfo

nolog:
	-rm -f test.log

newtest:
	cp $(from).in $(to).in
	cp $(from).ok $(to).ok
	cp -rf $(from).fixtures $(to).fixtures
	find $(to).fixtures -type f|while read f; do \
		cp "$$f" "$$f.tmp"; \
		sed 's@$(from)\.fixtures@$(to).fixtures@g' < "$$f.tmp" > "$$f"; \
		rm "$$f.tmp"; \
	done

