From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 19 Dec 2006 09:58:46 +0000
Subject: Re: [PATCH 5/8]: Move debugging macro to header file
Message-Id: <5640c7e00612190158l89a80a3l5776d76e11d59941@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
In-Reply-To: <5640c7e00612151347j33d8239ua0fabed666d4805f@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/19/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Shame on me - I think I forgot the EXPORT_SYMBOL. Can you please try the latest uploaded
> version - I have fixed it there.
> Gerrit

But the EXPORT_SYMBOL_GPL doesn't fix this:
> |  and now I get this:
> |  WARNING: Module
> |  /lib/modules/2.6.20-rc1davem20/kernel/net/dccp/ccids/lib/dccp_tfrc_lib.ko
> |  ignored, due to loop
> |  WARNING: Loop detected:
> |  /home/ian/tmp/lib/modules/2.6.20-rc1davem20/kernel/net/dccp/ccids/dccp_ccid3.ko
> |  needs dccp_tfrc_lib.ko which needs dccp_ccid3.ko again!
> |  WARNING: Module
> |  /lib/modules/2.6.20-rc1davem20/kernel/net/dccp/ccids/dccp_ccid3.ko
> |  ignored, due to loop
> |
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
