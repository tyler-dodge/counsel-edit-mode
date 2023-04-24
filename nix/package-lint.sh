unset PATH
for p in $baseInputs $buildInputs; do
  export PATH=$p/bin${PATH:+:}$PATH
done

function buildPhase() {
    ln -s $test_target test
    mkdir home
    export HOME=home/
    ${emacs}/bin/emacs -q --version
    wget -O melpazoid.el https://raw.githubusercontent.com/riscy/melpazoid/master/melpazoid/melpazoid.el
    ln -s "$counsel_edit_mode" counsel-edit-mode.el
    ${emacs}/bin/emacs -q -batch \
            --eval "(require 'package)" \
            --eval "(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\") t)" \
            --eval "(package-initialize)" \
            --eval "(package-refresh-contents)" \
            --eval "(package-install-file \"counsel-edit-mode.el\")" \
            --eval "(package-install-file \"melpazoid.el\")" \
            -l package-lint \
            --file "counsel-edit-mode.el" \
            --eval "(message \"[NOT RESPONSIBLE FOR WARNINGS PRIOR TO THIS POINT]\")" \
            --eval "(checkdoc-eval-current-buffer)" \
            --eval "(with-current-buffer \"*Style Warnings*\" (message \"%s\" (buffer-string)))" \
            --eval "(package-lint-current-buffer)" \
            --eval "(byte-compile-file \"$counsel_edit_mode\")" \
            --eval "(require 'melpazoid)" \
            --eval "(melpazoid-check-experimentals)" \
            --eval "(with-current-buffer \"*Package-Lint*\" (message \"%s\" (buffer-string)))" | tee $out
    STATUS="${PIPESTATUS[0]}"
    if [ $STATUS -gt 0 ]
    then
        rm $out
        exit $STATUS
    fi
}

function genericBuild() {
  buildPhase
}

