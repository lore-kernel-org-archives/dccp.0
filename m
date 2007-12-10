From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 10 Dec 2007 21:04:16 +0000
Subject: Re: [PATCH 8/8] [PATCH v2] [CCID3]: Interface CCID3 code with
Message-Id: <20071210210416.GB24046@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11971083882534-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Dec 08, 2007 at 10:06:28AM +0000, Gerrit Renker escreveu:
> This hooks up the TFRC Loss Interval database with CCID 3 packet reception.
> In addition, it makes the CCID-specific computation of the first loss
> interval (which requires access to all the guts of CCID3) local to ccid3.c.
> 
> The patch also fixes an omission in the DCCP code, that of a default /
> fallback RTT value (defined in section 3.4 of RFC 4340 as 0.2 sec); while
> at it, the  upper bound of 4 seconds for an RTT sample has  been reduced to
> match the initial TCP RTO value of 3 seconds from[RFC 1122, 4.2.3.1].
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

When interfacing we must make sure that ccid3 tfrc_lh_slab is created
and then tfrc_li_cachep is not needed. I'm doing this while keeping
the structure of the patches, i.e. one introducing, the other removing.
But we need to create tfrc_lh_slab if we want the tree to be bisectable.

I'm doing this and keeping your Signed-off-line, please holler if you
disagree for some reason.

- Arnaldo
