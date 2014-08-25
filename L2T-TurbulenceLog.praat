

procedure turbulence_log_columns
  # Define string constants for the columns of a Turbulence Tagging Log.
  .tagger         = 1
  .tagger$        = "TurbulenceTagger"
  .start_time     = 2
  .start_time$    = "StartTime"
  .end_time       = 3
  .end_time$      = "EndTime"
  .trials         = 4
  .trials$        = "NumberOfTrials"
  .tagged_trials  = 5
  .tagged_trials$ = "NumberOfTrialsTagged"
  # Gather the string constants into a vector.
  .slot1$ = .tagger$
  .slot2$ = .start_time$
  .slot3$ = .end_time$
  .slot4$ = .trials$
  .slot5$ = .tagged_trials$
  .length = 5
  # A string contant that will facilitate creating a new Turbulence Tagging Log
  # as a Praat Table object.
  .all_columns$ = .slot1$
  for i from 2 to .length
    .all_columns$ = .all_columns$ + " " + .slot'i'$
  endfor
endproc


procedure read_turbulence_log
  # Use the [.directory$] and [.filename$] strings to set up the path
  # from which the Turbulence Tagging Log is [.read_from$].
  .read_from$ = turbulence_log.directory$ + "/" + 
            ... filename_from_pattern.filename$
  # The [.write_to$] path is the same as the [.read_from$] path.
  .write_to$ = .read_from$
  # Read in the Turbulence Tagging Log
  printline Loading Turbulence Tagging Log
        ... 'filename_from_pattern.filename$' from 'turbulence_log.directory$'
  Read Table from tab-separated file... '.read_from$'
  Rename... 'turbulence_log.table_obj$'
  .praat_obj$ = selected$()
endproc


procedure initialize_turbulence_log
  # The [.read_from$] path is an empty string because the Turbulence Tagging
  # Log was not read from the filesystem.
  .read_from$ = ""
  # Set up the path that the Turbulence Tagging Log will be written to.
  .write_to$ = turbulence_log.directory$ + "/" +
           ... turbulence_log.experimental_task$ + "_" +
           ... participant.id$ + "_" +
           ... turbulence_log.initials$ + "turbulenceTagLog.txt"
  # Create a Praat Table object.
  printline Initializing blank Turbulence Tagging Log
        ... 'turbulence_log.table_obj$'
  Create Table with column names... 'turbulence_log.table_obj$'
                                ... 1
                                ... 'turbulence_log_columns.all_columns$'
  # Store the full name of the Praat Table object.
  .praat_obj$ = selected$()
  # Initialize the tagger's initials.
  select '.praat_obj$'
  Set string value... 1
                  ... 'turbulence_log_columns.tagger$'
                  ... 'turbulence_log.initials$'
  # Initialize the start time.
  @timestamp
  select '.praat_obj$'
  Set string value... 1 
                  ... 'turbulence_log_columns.start_time$' 
                  ... 'timestamp.time$'
  # Initialize the end time.
  @timestamp
  select '.praat_obj$'
  Set string value... 1 
                  ... 'turbulence_log_columns.end_time$'
                  ... 'timestamp.time$'
  # Initialize the number of trials whose target sequence contains a sibilant.
  select 'wordlist.praat_obj$'
  .n_trials = Get number of rows
  select '.praat_obj$'
  Set numeric value... 1
                   ... 'turbulence_log_columns.trials$'
                   ... 'wordlist.n_trials'
  # Initialize the number of trials tagged thus far (= 0).
  select '.praat_obj$'
  Set numeric value... 1
                   ... 'turbulence_log_columns.tagged_trials$'
                   ... 0
endproc


procedure turbulence_log
  # Import constants from the [session_parameters] namespace.
  .initials$             = session_parameters.initials$
  .workstation$          = session_parameters.workstation$
  .experimental_task$    = session_parameters.experimental_task$
  .testwave$             = session_parameters.testwave$
  .participant_number$   = session_parameters.participant_number$
  .activity$             = session_parameters.activity$
  .experiment_directory$ = session_parameters.experiment_directory$
  # Set up the [turbulence_log_columns] namespace.
  @turbulence_log_columns
  # A Turbulence Tagging Log only needs to be loaded if a checked segmented
  # Segmentation TextGrid has already been loaded to the Praat Objects list.
  if segmentation_textgrid.praat_obj$ <> ""
    # If a checked segmented Segmentation TextGrid has already been loaded,
    # then load a Turbulence Tagging Log.
    # Use the path that the checked segmented TextGrid was [.read_from$] to 
    # determine the [participant]'s [.id$].
    @participant: segmentation_textgrid.read_from$, .participant_number$
    # Use the [participant]'s [.id$] to set up the name of the Table object.
    .table_obj$ = participant.id$ + "_TurbLog" + .initials$
    # Set up the path to the [.directory$] of the Turbulence Tagging Logs.
    .directory$ = .experiment_directory$ + "/" + 
              ... "TurbulenceTagging" + "/" + 
              ... "Logs"
    # Set up the string [.pattern$] used to search for a Turbulence Tagging Log.
    .pattern$ = .directory$ + "/" +
            ... .experimental_task$ + "_" +
            ... .participant_number$ + "*" + 
            ... .initials$ + "turbulenceTagLog.txt"
    # Use the [.pattern$] to search for a Turbulence Tagging Log.
    @filename_from_pattern: .pattern$, "Turbulence Tagging Log"
    if filename_from_pattern.filename$ <> ""
      # If a Turbulence Tagging Log was found on the filesystem, then read it
      # in.
      @read_turbulence_log
      # Import string constants from the [read_turbulence_log] namespace.
      .read_from$ = read_turbulence_log.read_from$
      .write_to$  = read_turbulence_log.write_to$
      .praat_obj$ = read_turbulence_log.praat_obj$
    else
      # If no Turbulence Tagging Log was found on the filesystem, then a blank
      # one should be created at runtime.
      @initialize_turbulence_log
      # Import string constants from the [initialize_turbulence_log] namespace.
      .read_from$ = initialize_turbulence_log.read_from$
      .write_to$  = initialize_turbulence_log.write_to$
      .praat_obj$ = initialize_turbulence_log.praat_obj$
    endif
  else
    # If a checked segmented TextGrid has not been loaded to the Praat Objects
    # list, then don't load a Turbulence Tagging Log because it isn't possible
    # to tag turbulence events without a checked segmented TextGrid.
    .read_from$ = ""
    .write_to$  = ""
    .praat_obj$ = ""
  endif
endproc











