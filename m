From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sun, 04 Nov 2007 08:10:41 +0000
Subject: Re: [PATCH 3/9] [CCID2]: Replace read-only variable with constant
Message-Id: <5640c7e00711040110w1950f22as856a986b533ccc8a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200711031323.43503@strip-the-willow>
In-Reply-To: <200711031323.43503@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> This replaces the field member `numdupack', which was used as a read-only
> constant in the code, with a #define.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
