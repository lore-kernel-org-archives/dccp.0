From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 11 Oct 2008 07:35:33 +0000
Subject: Re: Protocol not attached
Message-Id: <20081011073533.GA9480@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Leandro -
| # lsmod
| Module                  Size  Used by
| dccp_tfrc_lib          17868  0
| dccp_ipv6              14916  2
| dccp_ipv4              14596  3 dccp_ipv6
| dccp                   58176  2 dccp_ipv6,dccp_ipv4
| 
| DCCP did not load the dccp_ccid2 module. Is this the problem?
| 
are there any news regarding this issue? If there is a problem I would
like to address it since I am submitting this patch set.
