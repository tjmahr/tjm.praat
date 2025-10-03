form Normalize TextGrid format
    sentence Textgrid_in
    sentence Textgrid_out
endform

if textgrid_out$ == ""
    textgrid_out$ = textgrid_in$
endif

Read from file: textgrid_in$
Save as text file: textgrid_out$
