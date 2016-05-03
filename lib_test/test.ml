open OUnit

let _ =
  let suite = "named_pipes" >::: [

  ] in
  OUnit2.run_test_tt_main (OUnit.ounit2_of_ounit1 suite)
