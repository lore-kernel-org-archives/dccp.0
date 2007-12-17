From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 17 Dec 2007 13:53:49 +0000
Subject: Re: [RFC]: Break up a patch in two (rfc3448bis changes to feedback reception)
Message-Id: <20071217135349.GA5205@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20071217125105.GE5128@ghostprotocols.net>
In-Reply-To: <20071217125105.GE5128@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| 	The end result should be equivalent, but please take a look and
That is a good catch - this patch was a pain to keep updated exactly due
to the many indentation levels. I had a quick look, the patch looks ok.

Just a small suggestion - since the RTT lookup code in tx_packet_recv()
is new, would it make sense to group it with the RTT validation, as e.g.

