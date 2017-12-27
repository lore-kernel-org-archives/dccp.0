From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Wed, 27 Dec 2017 14:51:33 +0000
Subject: [PATCH 00/12] drop unneeded newline
Message-Id: <1514386305-7402-1-git-send-email-Julia.Lawall@lip6.fr>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Drop newline at the end of a message string when the printing function adds
a newline.

The complete semantic patch that detects this issue is as shown below
(http://coccinelle.lip6.fr/).  It works in two phases - the first phase
counts how many uses of a function involve a newline and how many don't,
and then the second phase removes newlines in the case of calls where a
newline is used one fourth of the times or less.

This approach is only moderately reliable, and all patches have been
checked to ensure that the newline is not needed.

This also converts some cases of string concatenation to single strings in
modified code, as this improves greppability.

// <smpl>
virtual after_start

@initialize:ocaml@
@@

let withnl = Hashtbl.create 101
let withoutnl = Hashtbl.create 101

let ignore   ["strcpy";"strlcpy";"strcat";"strlcat";"strcmp";"strncmp";"strcspn";
    "strsep";"sprintf";"printf";"strncasecmp";"seq_printf";"strstr";"strspn";
    "strlen";"strpbrk";"strtok_r";"memcmp";"memcpy"]

let dignore = ["tools";"samples"]

let inc tbl k   let cell     try Hashtbl.find tbl k
    with Not_found ->
      let cell = ref 0 in
      Hashtbl.add tbl k cell;
      cell in
  cell := 1 + !cell

let endnl c   let len = String.length c in
  try
    String.get c (len-3) = '\\' && String.get c (len-2) = 'n' &&
    String.get c (len-1) = '"'
  with _ -> false

let clean_string s extra   let pieces = Str.split (Str.regexp "\" \"") s in
  let nonempty s     not (s = "") && String.get s 0 = '"' && not (String.get s 1 = '"') in
  let rec loop = function
      [] -> []
    | [x] -> [x]
    | x::y::rest ->
	if nonempty x && nonempty y
	then
	  let xend = String.get x (String.length x - 2) = ' ' in
	  let yend = String.get y 1 = ' ' in
	  match (xend,yend) with
	    (true,false) | (false,true) -> x :: (loop (y::rest))
	  | (true,true) ->
	      x :: (loop (((String.sub y 0 (String.length y - 2))^"\"")::rest))
	  | (false,false) ->
	      ((String.sub x 0 (String.length x - 1)) ^ " \"") ::
	      (loop (y::rest))
	else x :: (loop (y::rest)) in
  (String.concat "" (loop pieces))^extra

@r depends on !after_start@
constant char[] c;
expression list[n] es;
identifier f;
position p;
@@

f@p(es,c,...)

@script:ocaml@
f << r.f;
n << r.n;
p << r.p;
c << r.c;
@@

let pieces = Str.split (Str.regexp "/") (List.hd p).file in
if not (List.mem f ignore) &&
  List.for_all (fun x -> not (List.mem x pieces)) dignore
then
  (if endnl c
  then inc withnl (f,n)
  else inc withoutnl (f,n))

@finalize:ocaml depends on !after_start@
w1 << merge.withnl;
w2 << merge.withoutnl;
@@

let names = ref [] in
let incn tbl k v   let cell     try Hashtbl.find tbl k
    with Not_found ->
      begin
	let cell = ref 0 in
	Hashtbl.add tbl k cell;
	cell
      end in
  (if not (List.mem k !names) then names := k :: !names);
  cell := !v + !cell in
List.iter (function w -> Hashtbl.iter (incn withnl) w) w1;
List.iter (function w -> Hashtbl.iter (incn withoutnl) w) w2;

List.iter
  (function name ->
    let wth = try !(Hashtbl.find withnl name) with _ -> 0 in
    let wo = try !(Hashtbl.find withoutnl name) with _ -> 0 in
    if wth > 0 && wth <= wo / 3 then Hashtbl.remove withnl name
    else (Printf.eprintf "dropping %s %d %d\n" (fst name) wth wo; Hashtbl.remove withoutnl name; Hashtbl.remove withnl name))
  !names;

let it = new iteration() in
it#add_virtual_rule After_start;
it#register()

@s1 depends on after_start@
constant char[] c;
expression list[n] es;
identifier f;
position p;
@@

f(es,c@p,...)

@script:ocaml s2@
f << s1.f;
n << s1.n;
c << s1.c;
newc;
@@

try
  let _ = Hashtbl.find withnl (f,n) in
  if endnl c
  then Coccilib.include_match false
  else newc :    make_expr(clean_string (String.sub c 0 (String.length c - 1)) "\\n\"")
with Not_found ->
try
  let _ = Hashtbl.find withoutnl (f,n) in
  if endnl c
  then newc :    make_expr(clean_string (String.sub c 0 (String.length c - 3)) "\"")
  else Coccilib.include_match false
with Not_found -> Coccilib.include_match false

@@
constant char[] s1.c;
position s1.p;
expression s2.newc;
@@

- c@p
+ newc
// </smpl>

---

 arch/arm/mach-davinci/board-da850-evm.c                 |    4 ++--
 drivers/block/DAC960.c                                  |    4 ++--
 drivers/gpu/drm/amd/powerplay/hwmgr/smu7_hwmgr.c        |   12 ++++++++----
 drivers/gpu/drm/amd/powerplay/smumgr/fiji_smumgr.c      |    2 +-
 drivers/gpu/drm/amd/powerplay/smumgr/iceland_smumgr.c   |    2 +-
 drivers/gpu/drm/amd/powerplay/smumgr/polaris10_smumgr.c |    2 +-
 drivers/gpu/drm/amd/powerplay/smumgr/tonga_smumgr.c     |    2 +-
 drivers/media/usb/pvrusb2/pvrusb2-hdw.c                 |    3 ++-
 drivers/s390/block/dasd_diag.c                          |    3 +--
 drivers/scsi/hpsa.c                                     |    2 +-
 fs/dlm/plock.c                                          |    3 +--
 fs/ext2/super.c                                         |    2 +-
 fs/hpfs/dnode.c                                         |    3 ++-
 net/dccp/ackvec.c                                       |    2 +-
 net/openvswitch/conntrack.c                             |    4 ++--
 tools/perf/tests/dso-data.c                             |    9 +++++----
 16 files changed, 32 insertions(+), 27 deletions(-)
