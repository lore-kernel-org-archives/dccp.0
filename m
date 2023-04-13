From: Jakub Kicinski <kuba@kernel.org>
Date: Thu, 13 Apr 2023 14:45:14 +0000
Subject: Re: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <20230413074514.79cc036e@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, 13 Apr 2023 10:24:31 -0400 Willem de Bruijn wrote:
> Probably also relevant is whether/how the approach can be extended
> to [gs]etsockopt, as that was another example given, with the same
> challenge.

I had the same thought, given BPF filtering/integration with *etsockopt
is repeatedly giving us grief.
The only lesson from that I can think of is that we should perhaps
suffer thru the one-by-one conversions for a while. Pulling the cases
we inspected out into common code, rather than hope we can cover
everything in one fell swoop.
