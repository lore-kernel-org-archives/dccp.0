From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 13 Oct 2009 18:42:32 +0000
Subject: Re: [PATCHv2 1/4] First Patch on TFRC-SP. Copy base files from TFRC
Message-Id: <20091013184232.GF21809@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <4AD4B677.4000308@embedded.ufcg.edu.br>
In-Reply-To: <4AD4B677.4000308@embedded.ufcg.edu.br>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Oct 13, 2009 at 03:25:48PM -0300, Ivo Calado escreveu:
>      strange! I'm using the current DCCP test tree, branch dccp.
> Am I correct in use these rules?

Follow the rules in the latest Documentation/SubmittingPatches file,
that is:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob_plain;f=Documentation/SubmittingPatches;hb=HEAD

And that states:

-------------------------------------------------------------------

8) E-mail size.

When sending patches to Linus, always follow step #7.

Large changes are not appropriate for mailing lists, and some
maintainers.  If your patch, uncompressed, exceeds 300 kB in size,
it is preferred that you store your patch on an Internet-accessible
server, and provide instead a URL (link) pointing to your patch.

-------------------------------------------------------------------

As Jarek pointed out.

- Arnaldo
