From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 24 Oct 2007 12:28:20 +0000
Subject: [PATCH 0/1][RFC]: field name identifier conventions
Message-Id: <200710241328.20335@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Following the earlier discussion I have created two patches which shorten
the identifiers in some of the structs:
 
  1) A patch for the CCIDs, where I used the scheme suggested by Arnaldo
     (i.e. "c<N>{tx,rx}", e.g. hcrx->c2tx_ssthresh). This resulted in a 
     rather large patch (66k) and was rather disappointing - there was not
     much of the expected reduction in multiline expressions. For these
     reasons I think it is better to stick with the old scheme.
     But if people are still interested in this and may have different opinion,
     have a look at how the conversion looks at:

     http://www.erg.abdn.ac.uk/users/gerrit/dccp/rfc_patch_new_ccid_field_ids.diff


  2) A patch for ackvec.{c,h}. This follows next and simply replaces the `dccp' in
     the struct dccp_ackvec{,_record} fields. I like this patch because it makes
     the code easier to read.

     Arnaldo can you please indicate whether you find this patch acceptable - I am
     working on Ack Vectors (adding a tail pointer and fixing acknowledging old 
     Ack Vectors): if you are not ok with the patch, then I use the old scheme.
