" Copyright (C) 2012 Alfredo Di Napoli
" 
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
" 
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
" 
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.
" 
" Vim, arguably the best text-editor in the world.
" 
" Inspired from magnars' mark-multiple plugin.
"


if !exists("g:mark_multiple_started")
    let g:mark_multiple_started = 0
endif


if !exists("g:mark_multiple_in_normal_mode")
    let g:mark_multiple_in_normal_mode = 0
endif


if !exists("g:mark_multiple_in_visual_mode")
    let g:mark_multiple_in_visual_mode = 1
endif


" Leave space for user customization.
if !exists("g:mark_multiple_trigger")
    let g:mark_mutiple_trigger = "<C-n>"
endif


:execute "nnoremap ". g:mark_mutiple_trigger ." :call MarkMultiple()<CR>"
:execute "vnoremap ". g:mark_mutiple_trigger ." :call MarkMultiple()<CR>"
au InsertLeave * call MarkMultipleSubstitute()


fun! MarkMultiple()
    if GetWordUnderTheCursor() == ""
        let g:mark_multiple_started = 0
    else
        if g:mark_multiple_in_normal_mode
            call MarkMultipleNormal()
        endif

        if g:mark_multiple_in_visual_mode
            call MarkMultipleVisual()
        endif
    endif
endfunction


fun! MarkMultipleVisual()

    if !g:mark_multiple_started
        let g:mark_multiple_starting_curpos = getpos(".")
    endif

    let g:mark_multiple_started = 1
    call MarkMultiplePositionCursor()
    let g:mark_multiple_word = GetWordUnderTheCursor()
    call SelectWord()
    call HighlightWord()
    call MarkMultipleSwapModes()
endfunction


" This ensures the cursor is properly set.
fun! MarkMultiplePositionCursor()

    " Go back to the first available space
    :execute "normal F "
    normal %
    normal %
    normal l
    let g:mark_multiple_curpos = getpos('.')
endfun


"Currently unused: bugged and clunky.
fun! HighlightWord()
    let line_to_match = g:mark_multiple_curpos[1]
    let col_start = g:mark_multiple_curpos[2] - 1
    let col_end   = g:mark_multiple_curpos[2] + len(g:mark_multiple_word)
    let pattern = '\%'.line_to_match.'l\%>'.col_start.'c\%<'.col_end.'c'
    call matchadd('Search', pattern)
endfun


fun! MarkMultipleSwapModes()
    let g:mark_multiple_in_normal_mode = !g:mark_multiple_in_normal_mode
    let g:mark_multiple_in_visual_mode = !g:mark_multiple_in_visual_mode
endfunction


fun! MarkMultipleNormal()
    if g:mark_multiple_started
        "Go to the next word
        \<Esc>
        call setpos('.', g:mark_multiple_curpos)
        normal *
        nohlsearch
    endif

    call MarkMultipleSwapModes()
endfunction


fun! MarkMultipleSubstitute()

    if g:mark_multiple_started
        let new_word = GetWordUnderTheCursor()
        let start = g:mark_multiple_starting_curpos[1]
        let end   = g:mark_multiple_curpos[1]
        silent! execute start .','. end .  's/\v<' . expand(g:mark_multiple_word) .  '>/' . expand(new_word) .'/g'
        let g:mark_multiple_started = 0

        "Restore cursor under the last matched
        call setpos('.', g:mark_multiple_curpos)

        "Clear highlighting
        call clearmatches()
    endif
endfunction


" Call this to clear all the highlightings
fun! MarkMultipleClean()
    call clearmatches()
endfun


fun! GetWordUnderTheCursor()
        return expand("<cword>")
endfunction


fun! SelectWord()
    normal viw
endfunction
