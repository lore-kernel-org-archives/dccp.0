From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 13 Sep 2009 17:28:04 +0000
Subject: Re: [PATCH 3/5] Implement TFRC-SP calc of mean length of loss
Message-Id: <20090913172804.GA6109@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210909011945l1c44d1eap90329a4c6eb0480a@mail.gmail.com>
In-Reply-To: <cb00fa210909011945l1c44d1eap90329a4c6eb0480a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| Implement TFRC-SP calc of mean length of loss intervals accordingly to
| section 3 of RFC 4828
Sorry this also has problems.

--- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.c
+++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.c
@@ -67,10 +67,11 @@
 		}
 }
=20
-static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh)
+static void tfrc_sp_lh_calc_i_mean(struct tfrc_loss_hist *lh, __u8 curr_cc=
val)
 {
 	u32 i_i, i_tot0 =3D 0, i_tot1 =3D 0, w_tot =3D 0;
 	int i, k =3D tfrc_lh_length(lh) - 1; /* k is as in rfc3448bis, 5.4 */
+	u32 losses;
=20
 	if (k <=3D 0)
 		return;
@@ -78,6 +79,15 @@
 	for (i =3D 0; i <=3D k; i++) {
 		i_i =3D tfrc_lh_get_interval(lh, i);
=20
+		if (SUB16(curr_ccval,
+		    tfrc_lh_get_loss_interval(lh, i)->li_ccval) <=3D 8) {
+
+			losses =3D tfrc_lh_get_loss_interval(lh, i)->li_losses;
+
+			if (losses > 0)
+				i_i =3D div64_u64(i_i, losses);
+		}
+
(Both 'i_i' and 'losses' are u32, so could write "i_i /=3D losses" instead.)

However, this computation is done in the wrong place: here it is already too
late. The N/K in RFC 4828 refers to entering each individual interval I_0, =
so
the division (and the check whether this is a "short" interval) needs to be
done when adding the interval, in tfrc_sp_lh_interval_add(). (There also ex=
ists
a special rule for the open interval I_0, see RFC 5348, 5.3.)

A second problem is a divide-by-zero condition encoded in the above: if
i_i < losses, the result is 0, if all intervals are 0 then I_mean =3D 0, and
thus p =3D 1/I_mean triggers a panic. In all other cases, the integer arith=
metic
has the effect of floor(N/K), i.e. it decreases the interval length.

A way out (which does not fix the truncation problem) is to round up:

	if (losses > 0)
		i_i =3D DIV_ROUND_UP(i_i, losses);

In fact, we have to do this, to avoid the divide-by-zero condition.

The third problem is that the CCVal can be wrong, i.e. "less than 8" can
also mean that it just wrapped around one or more times. But this is noted
already in RFC 5622, it is a problem of the specification.

@@ -87,6 +97,11 @@
 	}
=20
 	lh->i_mean =3D max(i_tot0, i_tot1) / w_tot;
+	BUG_ON(w_tot =3D 0);
+	if (SUB16(curr_ccval, tfrc_lh_get_loss_interval(lh, 0)->li_ccval) > 8)
+		lh->i_mean =3D max(i_tot0, i_tot1) / w_tot;
+	else
+		lh->i_mean =3D i_tot1 / w_tot;
 }
The line above the BUG_ON is probably a leftover. For the BUG_ON, this would
be too late (division by zero).=20
In fact, the BUG_ON is not needed, due to testing for k <=3D 0, see
http://mirror.celinuxforum.org/gitstat//commit-detail.php?commit=EFf253c427=
2cd2aac95ccff46d3d2e1a495f22b1

@@ -127,7 +142,7 @@
 		return;
=20
 	cur->li_length =3D len;
-	tfrc_sp_lh_calc_i_mean(lh);
+	tfrc_sp_lh_calc_i_mean(lh, dccp_hdr(skb)->dccph_ccval);
 }
Should be division as per above.

--- dccp_tree_work5.orig/net/dccp/ccids/lib/loss_interval_sp.h
+++ dccp_tree_work5/net/dccp/ccids/lib/loss_interval_sp.h
@@ -73,7 +73,8 @@
 extern bool tfrc_sp_lh_interval_add(struct tfrc_loss_hist *,
 				    struct tfrc_rx_hist *,
 				    u32 (*first_li)(struct sock *),
-				    struct sock *);
+				    struct sock *,
+				    __u8 ccval);
This function already has the ccval available, so could use it instead
of just passing it through.
