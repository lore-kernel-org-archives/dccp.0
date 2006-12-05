From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Dec 2006 20:13:46 +0000
Subject: Re: [PATCH 0/7] [DCCP]: Further fixes and enhancements
Message-Id: <200612052013.47534@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00612051152o42a347b8o404187d4f4970c38@mail.gmail.com>
In-Reply-To: <5640c7e00612051152o42a347b8o404187d4f4970c38@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  - altering packet size makes no difference to packet rate (see
|  http://wand.net.nz/~perry/max_download.php ) at present
I sometimes think that we could edge out more throughput this way - but this
is already going towards CCID 4, we don't need to implement more than what is in the spec.
