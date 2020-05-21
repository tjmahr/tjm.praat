form Merge duplicated interval labels
  sentence TextGrid_in
  sentence Target_tier silence
  sentence TextGrid_out
endform

Read from file: textGrid_in$
@findNumberForTier: target_tier$

@labelMerger: "initialize", findNumberForTier.result

while labelMerger.has_next
	@labelMerger: "merge-or-step", findNumberForTier.result
endwhile

Save as text file: textGrid_out$


# Object for merging duplicated textgrid interval labels
procedure labelMerger: .method$, .tier_number

  if .method$ = "initialize"
      .current_position = 1
  endif

  if .method$ = "merge-or-step"
    can_merge = .current_label$ == .next_label$
    if can_merge == 1
      Remove right boundary: .tier_number, .current_position
      Set interval text: .tier_number, .current_position, .current_label$
    else
      .current_position = .current_position + 1
    endif
  endif


  if .method$ = "has_next"
    # .has_next is updated whenever procedure is invoked
  endif

  .intervals = Get number of intervals: .tier_number
  .current_label$ = Get label of interval: .tier_number, .current_position

  if .current_position < .intervals
    .has_next = 1
    .next_label$ = Get label of interval: .tier_number, .current_position + 1
  else
    .has_next = 0
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
