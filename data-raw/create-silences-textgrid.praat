form Make silence textgrid
    sentence Wav_file_in
    sentence Textgrid_out
endform
Read from file: wav_file_in$
To TextGrid (silences): 100, 0, -25, 0.1, 0.1, "silent", "sounding"
Save as text file: textgrid_out$
