From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 05 Dec 2007 14:13:10 +0000
Subject: Re: [PATCH v2 0/3][BUG-FIX]: Test tree updates and bug fixes
Message-Id: <20071205141310.GF4653@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Dec 05, 2007 at 11:19:44AM +0000, Gerrit Renker escreveu:
> This revision fixes a bug present in the per-socket allocation of RX history 
> entries; identification of this bug is thanks to Arnaldo Carvalho de Melo.
> 
> The bug was in not deallocating history entries when the allocation of 
> one array element failed. The solution in this revised patch set is the
> original one written by Arnaldo.

Ok, this one I posted with some other comments and explanations about
changes other than namespacing, renaming of some functions and removal
of functions not used in this patch.
 
- Arnaldo
