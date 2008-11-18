From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 18 Nov 2008 05:03:47 +0000
Subject: Re: [PATCH 1/5] dccp: Mechanism to resolve CCID dependencies
Message-Id: <20081118050346.GA3846@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
List-Id: <dccp.vger.kernel.org>
References: <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk>
To: dccp@vger.kernel.org


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

| > +	list_for_each_entry(entry, fn_list, node)
| > +		if (entry->feat_num == feat_num && entry->is_local == is_local)
| > +			return entry;
| > +		else if (entry->feat_num > feat_num)
| > +			break;
| 
| Personally, I would have put braces around this basic block.
| 
If it is possible to modify without disturbance, I attach a patch for this and
have changed it in the test tree.

I have checked that making this change does not affect subsequent
patches - it works with either variant.

--DocE+STaALJfprDB
Content-Type: text/x-diff; charset=us-ascii
Content-Description: Missing braces
Content-Disposition: attachment; filename="3.diff"

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -171,11 +171,12 @@ static struct dccp_feat_entry *dccp_feat
 {
 	struct dccp_feat_entry *entry;
 
-	list_for_each_entry(entry, fn_list, node)
+	list_for_each_entry(entry, fn_list, node) {
 		if (entry->feat_num == feat_num && entry->is_local == is_local)
 			return entry;
 		else if (entry->feat_num > feat_num)
 			break;
+	}
 	return NULL;
 }
 

--DocE+STaALJfprDB--
