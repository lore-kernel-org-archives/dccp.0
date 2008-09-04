From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Sep 2008 06:15:11 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080904061511.GA30756@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-9"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

This is an update with regard to Wei's comments. I have re-synched=20

	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree `dccp']
	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dshor=
tlog;h=DCcp

Also did some testing with a client that only supports CCID 2/3 talking to =
a client supporting
CCID 2/3/4. They could still negotiate and settle for a common CCID.

Change-Log:
-----------
	1. relaxed the requirement of checking each and every SP value in change_r=
ecv
	   to checking only the value that will actually be used/activated;
	2. fixed an error in yesterdays's update:
	   dccp_feat_is_valid_sp_val() takes an u8 value, not an u8 *pointer;
	3. added Wei's suggestion to skip over empty Confirms when activating the
	   negotiated features in dccp_feat_activate_values().

---------------------------------------------------------------------------=
-----------------	  =20
List of patches that were updated:
----------------------------------
v3 [PATCH 1/1] dccp: Process incoming Change feature-negotiation options=20
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;hZ146b97d5e93db2df075c0d820f492bb996d0e3

[PATCH 25/37] dccp: Feature activation handlers
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dcommi=
tdiff;h=C926c6aed3e444e8c88a768f063b2de8fd6ae760

---------------------------------------------------------------------------=
-----------------	  =20
Interdiff of the submitted changeset relative to yesterday's state:
---------------------------------------------------------------------------=
-----------------
 		1 file changed, 11 insertions(+), 3 deletions(-)
--- b/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1102,8 +1102,6 @@ static u8 dccp_feat_change_recv(struct list_head *fn,=
 u8=20
 	 */
 	entry =3D dccp_feat_list_lookup(fn, feat, local);
 	if (entry =3D NULL) {
-		if (!dccp_feat_sp_list_ok(feat, val, len))
-			goto unknown_feature_or_value;
 		/*
 		 * No particular preferences have been registered. We deal with
 		 * this situation by assuming that all valid values are equally
@@ -1121,6 +1119,9 @@ static u8 dccp_feat_change_recv(struct list_head *fn,=
 u8=20
 			defval =3D dccp_feat_default_value(feat);
 			if (dccp_feat_preflist_match(&defval, 1, val, len) > -1)
 				fval.sp.vec[0] =3D defval;
+		} else if (!dccp_feat_is_valid_sp_val(feat, fval.sp.vec[0])) {
+			kfree(fval.sp.vec);
+			goto unknown_feature_or_value;
 		}
=20
 		/* Treat unsupported CCIDs like invalid values */
@@ -1229,7 +1230,7 @@ static u8 dccp_feat_confirm_recv(struct list_head *fn=
, u8=20
 	 * SP value which the peer confirms, the remainder depends on @len.
 	 * Note that only the confirmed value need to be a valid SP value.
 	 */
-	if (!dccp_feat_is_valid_sp_val(feat, val))
+	if (!dccp_feat_is_valid_sp_val(feat, *val))
 		goto confirmation_failed;
=20
 	if (len =3D 1) {		/* peer didn't supply a preference list */
@@ -1471,6 +1472,13 @@ int dccp_feat_activate_values(struct sock *sk, struct
 	};
=20
 	list_for_each_entry(cur, fn_list, node) {
+		/*
+		 * An empty Confirm means that either an unknown feature type
+		 * or an invalid value was present. In the first case there is
+		 * nothing to activate, in the other the default value is used.
+		 */
+		if (cur->empty_confirm)
+			continue;
=20
 		idx =3D dccp_feat_index(cur->feat_num);
 		if (idx < 0) {
