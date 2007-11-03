From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 03 Nov 2007 23:51:50 +0000
Subject: Re: [PATCH 2/9] [CCID2]: Remove unused variable
Message-Id: <5640c7e00711031651l140594edhb1306761d9b643f8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200711031323.39901@strip-the-willow>
In-Reply-To: <200711031323.39901@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This removes a variable `ccid2hctx_sent' which is incremented but
> never referenced/read (i.e., dead code).
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
