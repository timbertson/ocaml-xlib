(* Simple Xlib application drawing a box in a window. *)
(* run with:
   ocaml Xlib.cma keysym.cma wikipedia-example.ml
*)

open Xlib

let () =
  (* open connection with the server *)
  let d = xOpenDisplay "" in
  let s = xDefaultScreen d in

  (* create window *)
  let w = xCreateSimpleWindow d (xRootWindow d s) 10 10 100 100 1
                                (xBlackPixel d s) (xWhitePixel d s) in

  (* set window name *)
  xStoreName d w Sys.argv.(0);

  (* select kind of events we are interested in *)
  xSelectInput d w [ExposureMask; KeyPressMask];

  (* map (show) the window *)
  xMapWindow d w;
  xFlush d;

  let dbl = w in
  let gc = xDefaultGC d s in

  (* connect the close button in the window handle *)
  let wm_delete_window = xInternAtom d "WM_DELETE_WINDOW" true in
  xSetWMProtocols d w wm_delete_window 1;

  (* event loop *)
  let e = new_xEvent() in
  try while true do
    xNextEvent d e;

    (* draw or redraw the window *)
    match xEventKind e with
    | XExposeEvent _ ->
        xDrawString d dbl gc 8 20 "Hello, Xlib!";

        xDrawRectangle d dbl gc 20 40  25 25;
        xDrawRectangle d dbl gc 45 65  25 25;
        xDrawArc d dbl gc 20 40  50 50  0 (90*64);
        xDrawArc d dbl gc 20 40  50 50  (180*64) (90*64);

    (* delete window event *)
    | XClientMessageEvent xclient ->
        let atom = xEvent_xclient_data xclient in
        if atom = wm_delete_window then
          raise Exit

    (* handle key press *)
    | XKeyPressedEvent event ->
        (* exit if q or escape are pressed *)
        let keysym = xLookupKeysym event 0 in
        if keysym = Keysym.xK_q ||
           keysym = Keysym.xK_Escape then
          raise Exit
        else
          let printable, c =
            let buf = "  " in
            let n, _ = xLookupString event buf in
            if (n = 1)
            then (true, buf.[0])
            else (false, '\000')
          in
          if printable then
            Printf.printf "Key '%c' pressed\n%!" c;

    | _ -> ()
  done with
  | Exit ->
      xDestroyWindow d w;
      (* close connection to server *)
      xCloseDisplay d;
;;

