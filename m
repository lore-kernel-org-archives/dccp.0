From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 29 Aug 2008 06:34:44 +0000
Subject: Re: [PATCH 09/37] dccp: Resolve dependencies of features on choice
Message-Id: <20080829063444.GF3557@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-10-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo:
| Em Thu, Aug 28, 2008 at 07:44:44PM +0200, Gerrit Renker escreveu:
| > This provides a missing link in the code chain, as several features implicitly
| > depend and/or rely on the choice of CCID. Most notably, this is the Send Ack Vector
| > feature, but also Ack Ratio and Send Loss Event Rate (also taken care of).
| > 
| > For Send Ack Vector, the situation is as follows:
| >  * since CCID2 mandates the use of Ack Vectors, there is no point in allowing
| >    endpoints which use CCID2 to disable Ack Vector features such a connection;
| > 
| >  * a peer with a TX CCID of CCID2 will always expect Ack Vectors, and a peer
| >    with a RX CCID of CCID2 must always send Ack Vectors (RFC 4341, sec. 4);
| > 
| >  * for all other CCIDs, the use of (Send) Ack Vector is optional and thus
| >    negotiable. However, this implies that the code negotiating the use of Ack
| >    Vectors also supports it (i.e. is able to supply and to either parse or
| >    ignore received Ack Vectors). Since this is not the case (CCID-3 has no Ack
| >    Vector support), the use of Ack Vectors is here disabled, with a comment
| >    in the source code.
| > 
| > An analogous consideration arises for the Send Loss Event Rate feature,
| > since the CCID-3 implementation does not support the loss interval options
| > of RFC 4342. To make such use explicit, corresponding feature-negotiation
| > options are inserted which signal the use of the loss event rate option,
| > as it is used by the CCID3 code.
| > 
| > Lastly, the values of the Ack Ratio feature are matched to the choice of CCID.
| > 
| > The patch implements this as a function which is called after the user has
| > made all other registrations for changing default values of features.
| > 
| > The table is variable-length, the reserved (and hence for feature-negotiation
| > invalid, confirmed by considering section 19.4 of RFC 4340) feature number `0'
| > is used to mark the end of the table.
| 
| Doesn't this belongs into struct ccid_operations? Why has the core feature
| negotiation have knowledge of any specific CCID? When people want to
| merge CCID 4, 5, etc will we need to change net/dccp/feat.c?
| 
| I think that this needs thus to go to struct ccid_operations, and then the feature
| negotiation code can just use use the ccid number to access:
| 
| struct ccid_operations *ccids[CCID_MAX]
| 
| ccids[ccid_number]->deps
|  
Your point is valid and one could do it this way. At the moment I can
not see an advantage. From experience, there is actually an advantage of
keeping all the dependencies in one file (feat.c): since CCID-4 use
mostly the same (TFRC) concepts as CCID-3, it can reuse the existing
ccid3_dependencies[] table, rather than copy-and-pasting it (this can
be seen in the commitdiff link for CCID-4 in the other posting).

For the moment, I would suggest keeping it in place. It is an easy patch
to do it later. The reason I am holding back here is that there is a
much larger potential for integration - as in the initial patches by
Tommi and Leandro, the mostly-identical TFRC functionality of CCID-3
and CCID-4 can be combined. Progress here has been impeded by waiting
for rfc3448bis-06 to reach RFC status, which it very soon:
ftp://ftp.rfc-editor.org/in-notes/authors/rfc5348.txt

But all this does not mean I disagree. There is a related spot which
I think should be CCID-specific: the "print" subroutine in
net/dccp/probe.c - at the moment, the CCIDs are hardcoded. Here it would
indeed be good to have a struct ccid_operations function pointer instead
of hardcoding the current CCID.
