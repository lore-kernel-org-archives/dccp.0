From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 21 Nov 2006 17:52:25 +0000
Subject: Re: [PATCH 4/6]: Simplify control flow of ccid3_hc_tx_send_packet
Message-Id: <5640c7e00611210952j21078b17ia0008fa6d9bef49a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.33274@strip-the-willow>
In-Reply-To: <200611211545.33274@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Simplify control flow of ccid3_hc_tx_send_packet
>
> This makes some logically equivalent simplifications, by replacing
> rc - values plus goto's with direct return statements.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
