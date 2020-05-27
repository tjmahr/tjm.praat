form Convert annotations into "silence" and "sounding"
  sentence Textgrid_in
  sentence Target_tier phones
  sentence Silence_regex ^$|sil|sp
  sentence Textgrid_out
endform

Read from file: textgrid_in$

@findNumberForTier: target_tier$

Replace interval texts:
... findNumberForTier.result, 1, 0,
... silence_regex$, "silent", "Regular Expressions"

Replace interval texts:
... findNumberForTier.result, 1, 0,
... "^((?!silent).)*$", "sounding", "Regular Expressions"

Save as text file: textgrid_out$

# Find the number of the (last) tier with a given name
procedure findNumberForTier: .target_tier$
  .tiers = Get number of tiers
  .result = 0

  for .tier_i to .tiers
    .tier_i_name$ = Get tier name: .tier_i
      if .tier_i_name$ == .target_tier$
        .result = .tier_i
      endif
  endfor

endproc
