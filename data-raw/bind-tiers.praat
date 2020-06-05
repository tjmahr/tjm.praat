form Copy tiers from one textgrid (sender) onto another (reciever)
  sentence Textgrid_receiver
  sentence Textgrid_sender
  sentence Tiers_to_pull
  sentence Textgrid_out
endform

Read from file: textgrid_receiver$
id_tg_receiver = selected("TextGrid")

Read from file: textgrid_sender$
id_tg_sender = selected("TextGrid")

Create Strings as tokens: tiers_to_pull$, ","
id_str_tiers_to_pull = selected("Strings")

@stringsIter: "tiers", id_str_tiers_to_pull, "initialize"

while stringsIter.tiers.has_next
  @stringsIter("tiers", id_str_tiers_to_pull, "next")
  selectObject: id_tg_sender

  # Pull tier
  @findNumberForTier: stringsIter.tiers.next$
  Extract one tier: findNumberForTier.result
  id_tier = selected("TextGrid")

  # Bind it
  selectObject: id_tg_receiver
  plusObject: id_tier
  Merge
  id_tg_temp = selected("TextGrid")

  # Clean up
  selectObject: id_tg_receiver
  plusObject: id_tier
  Remove

  id_tg_receiver = id_tg_temp
endwhile

selectObject: id_tg_receiver
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

# An iterator for a list of strings
procedure stringsIter: .iter_name$, .id, .method$
    selectObject: .id

    # create a private namespace for this strings list iterator
    .list$ = .iter_name$

    if .method$ = "initialize"
        .'.list$'.length = Get number of strings
        .'.list$'.index = 0
    endif

    if .method$ = "next"
        .'.list$'.index = .'.list$'.index + 1
        .'.list$'.next$ = Get string: .'.list$'.index
    endif

    if .method$ = "has_next"
        # .has_next is updated whenever procedure is invoked
    endif

    if .'.list$'.index < .'.list$'.length
        .'.list$'.has_next = 1
    else
        .'.list$'.has_next = 0
    endif
endproc
