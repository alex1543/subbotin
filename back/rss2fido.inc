
  num_tplusr := 1;
  // null par_cfg^
  num_rss := 1;
  while (par_cfg^[num_rss][num_t][num_tplusr] <> '') do
  begin
    num_t := 1;
    while (par_cfg^[num_rss][num_t][num_tplusr] <> '') do
    begin
      num_tplusr := 1;
      while (par_cfg^[num_rss][num_t][num_tplusr] <> '') do
      begin
        par_cfg^[num_rss][num_t][num_tplusr] := '';
        inc(num_tplusr);
      end;

      inc(num_t);
    end;
    inc(num_rss);
  end;
  num_tplusr := 1; num_rss := 1; num_t := 1;


    sim_lang_id := '@';
    sim_comment := ';';

    const_cfg[1] := 'Name';
    const_cfg[2] := 'Adress';
    const_cfg[3] := 'Post';
    const_cfg[4] := 'out';
    const_cfg[5] := 'master';
    const_cfg[6] := 'template';
    const_cfg[7] := 'language';

    const_cfg[8] := 'post_base';
    const_cfg[9] := 'post_format';
    const_cfg[10] := 'post_from';
    const_cfg[11] := 'post_to';
    const_cfg[12] := 'post_fadress';
    const_cfg[13] := 'post_tadress';
    const_cfg[14] := 'post_subj';
    const_cfg[15] := 'post_tearline';
    const_cfg[16] := 'post_origin';
    const_cfg[17] := 'post_flag';
    const_cfg[18] := 'exec';
    const_cfg[19] := 'create';
    const_cfg[20] := '';

    post_out_base := const_cfg[3];
    post_in_base := const_cfg[8];

    def_base[1] := 'squish';
    def_base[2] := 'jam';
    def_base[3] := 'msg';

    atr_msg[1] := 'Private';
    atr_msg[2] := 'Received';
    atr_msg[3] := 'Attach';
    atr_msg[4] := 'Orphan';
    atr_msg[5] := 'Local';
    atr_msg[6] := 'FRq';
    atr_msg[7] := 'RRc';
    atr_msg[8] := 'URq';

    atr_msg[9] := 'Crash';
    atr_msg[10] := 'Sent';
    atr_msg[11] := 'Transit';
    atr_msg[12] := 'Kill';
    atr_msg[13] := 'Hold';
    atr_msg[14] := 'RRq';
    atr_msg[15] := 'ARq';
    atr_msg[16] := 'Scanned';

    atr_in_msg[1] := maPrivate;
    atr_in_msg[2] := maReceived;
    atr_in_msg[3] := maAttach;
    atr_in_msg[4] := maOrphan;
    atr_in_msg[5] := maLocal;
    atr_in_msg[6] := maFRq;
    atr_in_msg[7] := maRRc;
    atr_in_msg[8] := maURq;

    atr_in_msg[9] := maCrash;
    atr_in_msg[10] := maSent;
    atr_in_msg[11] := maTransit;
    atr_in_msg[12] := maKill;
    atr_in_msg[13] := maHold;
    atr_in_msg[14] := maRRq;
    atr_in_msg[15] := maARq;
    atr_in_msg[16] := maScanned;

