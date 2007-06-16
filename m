From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 16 Jun 2007 22:54:51 +0000
Subject: Re: [PATCH 3/6]: Migrate to new naming scheme, using macro to declare cache
Message-Id: <5640c7e00706161554p4f5333c4v2ec9fa25371e758c@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706111341.49697@strip-the-willow>
In-Reply-To: <200706111341.49697@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/12/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [TFRC]: Migrate to new naming scheme, using macro to declare cache
>
I agree totally with the intent. I reworked li_hist as well but
Arnaldo decided to do in a better way and I think he'll want the same
for this also.

See his patch (which is in Dave M's tree now) at:
http://www.mail-archive.com/dccp@vger.kernel.org/msg01879.html

I also suspect his patch will stop yours applying.

Ian
-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
