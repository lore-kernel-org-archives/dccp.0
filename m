From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 25 Sep 2007 02:45:26 +0000
Subject: Re: Towards the ccid-3 and ccid-4 integration
Message-Id: <5640c7e00709241945r1ac995e7t90f690cc855a38bf@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
In-Reply-To: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 9/25/07, ツ Leandro Sales <leandroal@gmail.com> wrote:
> Hi list,
>   I'm currently trying to define the steps in order to get a good
> patchset for the initial ccid-4 implementation. Thus, I'd like to
> discuss with all of you some topics and procedures:
>
> - Rewrite all the patches (from me and Tommi) and resubmit to Gerrit
> as a unique patchset, as suggested by Ian. Besides, ask Gerrit to
> overwrite the current ccid4 branch;
> - Identify and provide common code between ccid-4 and ccid-3.
>   1 - minor functions from ccid-3.c to ccid-3.h and include it (.h) in
> the ccid-4.c, as suggested by Ian and Arnaldo
>   2 - for more complex functions, write a dccp_ccid3_lib.ko, as
> suggested by arnaldo
>
> Please, let me know if I've forgot something.
>
> Leandro.

Sounds great to me.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
