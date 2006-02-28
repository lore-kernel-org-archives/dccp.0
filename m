From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 28 Feb 2006 20:28:34 +0000
Subject: Re: [PATCH] Mandatory Option Draft Cleanup
Message-Id: <39e6f6c70602281228v2e5b5745r1a9281ae97c6ac70@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060222113802.GB21876@c3po.0xdef.net>
In-Reply-To: <20060222113802.GB21876@c3po.0xdef.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/28/06, Hagen Paul Pfeifer <hagen@jauu.net> wrote:
>
> According to dccp draft (draft-ietf-dccp-spec-13.txt) section 5.8.2 (Mandatory
> Option) the following patch correct the handling of the following cases:
>
> 1) "... and any Mandatory options received on DCCP-Data packets MUST be
>    ignored."
>
> 2) "The connection is in error and should be reset with Reset Code 5, ...
>    if option O is absent (Mandatory was the last byte of the option list), or
>    if option O equals Mandatory."
>
>
> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>

Thanks, I got this one merged already, take a look at:

http://www.kernel.org/git/?p=linux/kernel/git/acme/net-2.6.17.git;a=summary

Will submit to Dave later today.

- Arnaldo
