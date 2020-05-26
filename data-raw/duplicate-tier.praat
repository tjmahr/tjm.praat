form Duplicate a TextGrid tier
  sentence Textgrid_in
  sentence Target_tier phones
  sentence Duplicate_name phones2
  choice Duplicate_position: 1
    button last
    button first
    button before
    button after
  sentence Textgrid_out
endform

Read from file: textgrid_in$

# Find and duplicate tier
@findNumberForTier: target_tier$
tiers = Get number of tiers
@setDuplicatePosition: duplicate_position$, findNumberForTier.result, tiers

Duplicate tier:
... findNumberForTier.result,
... setDuplicatePosition.result,
... duplicate_name$

Save as text file: textgrid_out$


procedure setDuplicatePosition: .position$, .current_num, .total_tiers
    if .position$ = "last"
        .result = .total_tiers + 1
    endif

    if .position$ = "first"
        .result = 1
    endif

    if .position$ = "before"
        .result = .current_num
    endif

    if .position$ = "after"
        .result = .current_num + 1
    endif
endproc

# Find the number of the (last) tier with a given name
procedure findNumberForTier: .target_tier$
  .tiers = Get number of tiers
  .result = 0

  for tier_i to .tiers
    tier_i_name$ = Get tier name: tier_i
      if tier_i_name$ == .target_tier$
        .result = tier_i
      endif
  endfor

endproc
