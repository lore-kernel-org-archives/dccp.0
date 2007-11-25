From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 25 Nov 2007 16:39:39 +0000
Subject: Re: [PATCH 06/18] [DCCP]: Initialize dccp_sock before calling the ccid constructors
Message-Id: <20071125163939.GA5783@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1195950103-18102-7-git-send-email-acme@redhat.com>
In-Reply-To: <1195950103-18102-7-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| This is because in the next patch CCID2 will assume that dccps_mss_cache is
| non-zero.
| 
Good catch - in the test tree this problem didn't occur since the CCIDs
are initialised after everything else has been done (i.e. only after the
handshake has completed, which is much later than init_sock()).		

