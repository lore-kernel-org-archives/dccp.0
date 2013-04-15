From: Samuel Jero <sj323707@ohio.edu>
Date: Mon, 15 Apr 2013 16:52:01 +0000
Subject: [RFC][PATCH] tfrc: Correct 2nd Loss Interval Handling
Message-Id: <516C3031.4050405@ohio.edu>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------enigEF0FCE26213C9ABA8F40853E"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--------------enigEF0FCE26213C9ABA8F40853E
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

I have identified a bug in CCID 3's loss interval code affecting the 2nd =
loss
interval. Essentially, the bug is that CCID 3 doesn't create the 2nd loss=

interval until the loss that starts the 3rd interval. Therefore, the 2nd =
loss
interval can't be used to adjust the loss interval rate sent back to the =
sender
until another loss occurs.

I have observed this issue resulting in connections that maintain a very =
low
sending rate for >30 seconds because the computed loss event rate from th=
e
first interval is 1 in 33 or so. When the 2nd loss finally occurs, the co=
mputed
loss event rate suddenly jumps to 1 in 2000 or so and the allowed sending=
 rate
increases dramatically. See [1] for a time sequence graph of one of these=

connections.

RFC4342 (which is consistent with RFC3448 and 5348) defines a loss interv=
al
as at most one round-trip time's worth of packets that may be lost follow=
ed by
an arbitrarily long series of non-dropped packets (6.1). This, of course,=

doesn't work for the first interval so 3448 and 5348 require the sender t=
o
compute an artificial loss interval length for this first interval based =
on
the receive rate (6.3.1). To compute the loss event rate the receiver is
supposed to calculate the average loss interval length over the last 8
intervals. The current loss interval (i.e. the currently growing one) is =
only
included if it increases the average loss interval length (5.4).

The way this is implemented currently, the first loss interval structure =
is
created in tfrc_lh_interval_add() (loss_interval.c) when the first packet=

loss occurs. It's length is artificially computed as specified in the RFC=
s.
The bug is that a second loss interval structure is not created at this p=
oint
for the new loss interval that starts with this first loss (I interpret 6=
=2E3.1
to imply that the first loss ends the first loss interval).

With every packet received, the receiver calls tfrc_update_i_mean() to up=
date
the loss event rate by updating the current loss event length. However, i=
f
there is only one loss event structure this function returns before recom=
puting
the loss event rate. That behavior is correct, because we don't want to t=
amper
with the artificially computed first loss event length. If we had that se=
cond
loss interval structure, we could update its length and include it in the=
 loss
event rate if/when it became big enough to increase the average loss inte=
rval
length and thus decrease the loss event rate.

When the second loss finally occurs, tfrc_lh_interval_add() is called aga=
in.
This time the function overwrites the length of the first loss interval s=
tructure
with the number of packets since the first loss, in effect deleting the f=
irst loss
interval and replacing it by the second. The function then creates a new =
loss
interval structure for the loss interval starting with the second loss.

(This actually works correctly on all later loss intervals because then t=
he
"current" loss interval structure is actually the current loss interval, =
so this
code just sets its final length and adds a new loss interval structure fo=
r the
new loss interval)

This new loss interval structure will be updated by tfrc_update_i_mean() =
and
can affect the average loss interval length if it becomes long enough. Fr=
om
this point on the code will function as the RFCs expect.

My fix (patch below) is simply to add a second loss event structure to
represent the newly started loss event at the time the first loss is dete=
cted.


[1] http://www.sjero.net/software/dccp/images/dccp_ccid3_2nd_loss_interva=
l_bug.png

--=20
Samuel Jero
Masters Student
Computer Science
Internetworking Research Group
Ohio University

---
Signed-off-by: Samuel Jero <sj323707@ohio.edu>
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss=
_interval.c
index 47045e1..ad24819 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -198,9 +198,21 @@ bool tfrc_lh_interval_add(struct tfrc_loss_hist *lh,=
 struct tfrc_rx_hist *rh,
 	cur->li_ccval	  =3D cong_evt->tfrchrx_ccval;
 	cur->li_is_closed =3D false;
=20
-	if (++lh->counter =3D=3D 1)
+	if (++lh->counter =3D=3D 1) {
 		lh->i_mean =3D cur->li_length =3D (*calc_first_li)(sk);
-	else {
+		cur->li_is_closed =3D true;
+		cur =3D tfrc_lh_demand_next(lh);
+		if (unlikely(cur =3D=3D NULL)) {
+			DCCP_CRIT("Cannot allocate/add loss record.");
+			return false;
+		}
+		++lh->counter;
+		cur->li_seqno	  =3D cong_evt_seqno;
+		cur->li_ccval	  =3D cong_evt->tfrchrx_ccval;
+		cur->li_is_closed =3D false;
+		cur->li_length    =3D dccp_delta_seqno(cur->li_seqno,
+				 tfrc_rx_hist_last_rcv(rh)->tfrchrx_seqno) + 1;
+	} else {
 		/* RFC 5348, 5.3: length of the open loss interval I_0 */
 		cur->li_length =3D dccp_delta_seqno(cur->li_seqno,
 				 tfrc_rx_hist_last_rcv(rh)->tfrchrx_seqno) + 1;


--------------enigEF0FCE26213C9ABA8F40853E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with undefined - http://www.enigmail.net/

iQIcBAEBAgAGBQJRbDA3AAoJEPUrqO1w+kIcqYgQALKKd7I6r+ODB2xTVgzt8hKF
qQaUNuD/woLtp60qyNl6EYnNVXCiGROlz9goPjwJ6W4sdbDFk314OQlUxKgwbeID
y7GT4UxeOxNrzW3rsQ56NJ0XpW756zHG2z7R0TGzX7+KFex+cE+6fdOiSVEaUvp0
W/b8lLV4BIs3RLc7tNQvmQvhMHX/udmKbj/brBVxqiOJznzzlUjjLklLQY0vs9o9
FRf8orEhXutMSwhyrWEEs9Ta4bA1oKWC6hpX1Ub7X/pZYra2rriPt4YY4mcLHFpJ
bQUtAcxA4VjguLsPe9pgZdhBwCQJzP4odHoW7Gz+5zthYiSoarcueIBhMUZv+QeK
xzGXcHU1c8SJQ3p3JHwPAtv/2wPnDyez9pN/d30BD9Xizn39MYyoE71uHn94oktR
igJzuNnQjiN6ye1FnHllcM/D1f+WNQ7cS0zjiCfjyS7ihrcKWFW6IwW7GhHjiuuZ
pnkVvqxT+g/QU+Wij7S/GWykwB1ouXem49RxUJGUBvWK+P0vk4RoDqcilVqdW8VG
PUZmPJuJ2debLSgWVSq3mJBQ28Gj8QdoZ9CruGXLmzjcpMb3uplme0EEZtwvkX3H
UOloD3D/90j/fxAwL3fscQ/0lk/p7/UGQFBGMoMOVTWUGtPVwMIy9mVDcn/eJu5V
HUzUdpy3C+4RCfzWYSvk
=bKRu
-----END PGP SIGNATURE-----

--------------enigEF0FCE26213C9ABA8F40853E--
