From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Jan 2007 13:30:29 +0000
Subject: Re: [PATCH 0/5]: Revised older backlog
Message-Id: <200701041330.29696@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701031307.56132@strip-the-willow>
In-Reply-To: <200701031307.56132@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 1/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > This is a revision of the earliest patches in the backlog,the
|  > more recent ones will be sent separately.
|  >
|  Can you tell us what was revised?

The breakdown of individual changes is as follows: (you can also use interdiff against the
previously submitted patches, I state the links below):

Patch 1: "Macros for 48-bit sequence number arithmetic"
         Previous: http://www.mail-archive.com/dccp@vger.kernel.org/msg01158.html
	 CHANGE:   use the convention that macros are upper-case (was not previously)

Patch 2: "Signed variant of dccp_delta_seqno"
	 Previous: http://www.mail-archive.com/dccp@vger.kernel.org/msg01159.html
	 CHANGE:   1) Tossed out the unnecessary _add48/_sub48 macros (covered already)
		   2) Clarified the commit message (was not very clear before) 

Patch 3: "Make `before' relation unambiguous"
	 Previous: http://www.mail-archive.com/dccp@vger.kernel.org/msg01161.html
         CHANGE:   Removed the hunk which affected `max48' (since not really necessary)
         => Please note: The TCP variant of this new definition has been withdrawn, 
                          on the grounds that old code depends on it. I still maintain
                          that the new definition is useful and a better choice for DCCP.

Patch 4: "Fix for follows48"
	 Previous: http://www.mail-archive.com/dccp@vger.kernel.org/msg01160.html
	 CHANGE:   No code change, merely the commit message has been reformatted.

Patch 5: "Introduce macro for incrementing modulo-48"
         => This is a brand-new patch :), it has not been posted before.
             I decided to lump it in with the others since it belongs to the sequence
             number arithmetic (and relates to some email questions I sent).

Gerrit
             

