form: "Create a spectrogram"
  infile: "Wav_file_in", ""
  positive: "Max_frequency", "5000"
  outfile: "Spectrogram_out", ""
endform
Read from file: wav_file_in$
Pre-emphasize (in-place): 50
To Spectrogram: 0.005, max_frequency, 0.002, 20, "Gaussian"
Save as text file: spectrogram_out$
