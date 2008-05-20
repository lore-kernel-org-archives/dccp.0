From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 20 May 2008 14:53:00 +0000
Subject: Re: DCCP kernel crash during feature negotiation
Message-Id: <20080520145300.GA22697@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <4832D844.8010205@gmail.com>
In-Reply-To: <4832D844.8010205@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Dear Alessandro,

thank you very much for reporting and especially for providing a helpful
capture file.

I am sorry, but you are not using the test tree. 

The problems you state are both known bugs in the feature negotiation of
the mainline kernel.

The implementation can identified in the DCCP-Request/Response handshake:
 * The old implementation exchanges singleton values. This is why
   CCID-3 ends up talking to CCID-2, there is no real "negotiation".
 * The new implementation uses lists for all server-priority values
   - the Request contains Change L/R options from the client;
   - the Response has the Confirm R/L options from the server plus Change L/R;
   - the Ack and/or DataAcks sent by the client contain the Confirm R/L for
     the server-options sent in the Response, completing this handshake.


So please, can you try again to dowload the test tree, using either

 (a) Snapshot patch from
     http://www.erg.abdn.ac.uk/users/gerrit/dccp/testing_dccp/test-tree/ 
     (It should apply without a single problem; any problem - please do let me know).

 (b) Pull the tree by using

     git checkout -b dccp master		
     git pull git://eden-feed.erg.abdn.ac.uk/dccp_exp +dccp:dccp

     This checks out a fresh subtree `dccp' and pulls the subtree.

Another quick test is to run a "wc -l net/dccp/feat.c". If > 1500 then
it is the test tree, otherwise it is not.

People stumbled over this before - I'd welcome suggestions to make
pulling the test tree easier. A subtree had been chosen to avoid messing
up people's `master' branches.


> P.S. In the mainline kernel (2.6.22 version) this does not happen.
> If we do not load the modules, the communication never starts.
These differences are probably due to differences between 2.6.22 and
2.6.26-rc2. But the feature negotiation is broken in both.


Regarding the struct dccp_so_feat, there was an earlier suggestion and
request for comments to deprecate struct dccp_so_feat in favour of
dedicated socket options - it would be good to have input/suggestions
for this.


In the test tree, this replacement is in part available already, with
regard to CCIDs, it has the following socket options 
 * DCCP_SOCKOPT_TX_CCID sets/gets the TX CCID,
 * DCCP_SOCKOPT_RX_CCID is the same for the RX CCID, 
 * DCCP_SOCKOPT_CCID    sets both (a common case).

(Further information is in Documentation/networking/dccp.txt)

Gerrit
