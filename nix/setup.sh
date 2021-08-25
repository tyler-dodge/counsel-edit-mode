unset PATH
for p in $baseInputs $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

function buildPhase() {
    cp -r $test_target test
    chmod -R u+w test 
    ${emacs}/bin/emacs -q --version
    yes yes | ${emacs}/bin/emacs -q -batch -l $counsel_edit_mode -l ert-runner
    mkdir $out
}

function genericBuild() {
  buildPhase
}
