OCTAVE ?= octave-cli
MATLAB ?= matlab

all: check-octave check-matlab

m-unit-tests/src/mtest.m:
	git clone https://git.dynare.org/Dynare/m-unit-tests

check-octave: m-unit-tests/src/mtest.m
	@cd tests ;\
	$(OCTAVE) --no-init-file --silent --no-history --eval "addpath([pwd() '/../m-unit-tests/src']); runalltests" && [ ! -f ./failed ] && [ -f ./pass ]

check-matlab: m-unit-tests/src/mtest.m
	@$(MATLAB)  -nosplash -nodisplay -r "addpath([pwd '/m-unit-tests/src']); cd tests; runalltests; quit" && [ ! -f ./tests/failed ] && [ -f ./tests/pass ]

check-clean:
	rm -f tests/*_test_*.m tests/*.csv tests/*.xls tests/*.xlsx tests/*.mat tests/failed tests/datafile_for_test
	rm -f git.info git.last-commit-hash tests/pass tests/failed tests/*.spc
	rm -rf m-unit-tests
