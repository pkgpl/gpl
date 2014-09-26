help:
	@echo ""
	@echo "Gpl library"
	@echo ""
	@echo "Please modify compiler in gpl/compiler.py (F90, CC ...)"
	@echo "then type: make install"
	@echo ""

# scons
SC_COMPILE= scons -Q
SC_CLEAN= scons -Q -c
SC_INSTALL= scons -Q install
SC_UNINSTALL= scons -Q -c install

# install
install: env generator_install lib_install include_install program_install script_install

# environment
ENV_DIR= ./etc
ENV_SH= $(ENV_DIR)/env.sh
GPLROOT=$(PWD)
env:
	mkdir -p $(ENV_DIR)
	@echo "export GPLROOT=`pwd`" > $(ENV_SH)
	@echo 'export PYTHONPATH=$$GPLROOT:$$PYTHONPATH' >> $(ENV_SH)
	@echo 'export RUBYLIB=$$GPLROOT:.:$$RUBYLIB' >> $(ENV_SH)
	@echo 'export PATH=$$GPLROOT/bin:$$PATH' >> $(ENV_SH)
	export GPLROOT=$(GPLROOT)
	export PYTHONPATH=$(GPLROOT):$(PYTHONPATH)
	export PATH=$(GPLROOT)/bin:$(PATH)
env_clean:
	rm -rf $(ENV_DIR)

# libraries
generator_install:
	@cd src/generator; $(SC_INSTALL)
generator_clean:
	@cd src/generator; $(SC_CLEAN)
generator_distclean: generator_clean
	@cd src/generator; $(SC_UNINSTALL)

lib_compile:
	@cd src; $(SC_COMPILE)
lib_install: lib_compile
	@cd src; $(SC_INSTALL)
lib_clean:
	@cd src; $(SC_CLEAN)
lib_distclean:
	@cd src; $(SC_UNINSTALL); $(SC_CLEAN)

# include files
include_install:
	@cd src; $(SC_INSTALL)_include
include_clean:
	@cd src; $(SC_UNINSTALL)_include

# programs
program_compile:
	@cd src/programs; $(SC_COMPILE)
program_install: program_compile
	@cd src/programs; $(SC_INSTALL)
program_clean:
	@cd src/programs; $(SC_CLEAN)
program_distclean: program_clean
	@cd src/programs; $(SC_UNINSTALL)
program_document:
	@cd src/programs; rake
program_document_clean:
	@cd src/programs; rake clobber

# scripts
script_install:
	@cd script; $(SC_INSTALL)
script_clean:
	@cd script; $(SC_CLEAN)
script_distclean:
	@cd script; $(SC_UNINSTALL)

test:
	@cd src/test; pfunit

# clean
clean: env_clean script_distclean program_distclean include_clean generator_install lib_distclean generator_distclean
	rmdir ./bin ./include ./lib
	rm gpl/*.pyc gpl/py/*.pyc
#clean: env_clean script_distclean 
#	rmdir ./bin
