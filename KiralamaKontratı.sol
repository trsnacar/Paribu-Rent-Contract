// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract KiralamaKontrati {
    // Evin mi yoksa dükkanın mı olduğunu belirten bir enum tipi
    enum MulkTipi { Ev, Dukkan }

    // Mülk sahibi bilgilerini barındıran yapı
    struct MulkSahibi {
        address payable sahipAdresi;
        string isim;
        MulkTipi mulkTipi;
        string mulkAdresi;
    }

    // Kiralama bilgilerini barındıran yapı
    struct Kiralama {
        MulkTipi mulkTipi;
        string mulkAdresi;
        address payable kiraci;
        uint256 baslangicTarihi;
        uint256 bitisTarihi;
        bool kirada;
    }

    // Mülk sahiplerini saklamak için eşleme
    mapping(address => MulkSahibi) public mulkSahipleri;
    // Kiralama bilgilerini saklamak için eşleme
    mapping(string => Kiralama) public kiralamalar;

    // Sadece mülk sahibinin yapabileceği işlemler için kontrol
    modifier sadeceSahip(string memory mulkAdresi) {
        require(mulkSahipleri[msg.sender].sahipAdresi == msg.sender, "Bu işlemi sadece mülk sahibi yapabilir.");
        require(keccak256(abi.encodePacked(mulkSahipleri[msg.sender].mulkAdresi)) == keccak256(abi.encodePacked(mulkAdresi)), "Bu mülk size ait değil.");
        _;
    }

    // Mülk eklemek için fonksiyon
    function mulkEkle(string memory isim, MulkTipi mulkTipi, string memory mulkAdresi) public {
        mulkSahipleri[msg.sender] = MulkSahibi({
            sahipAdresi: payable(msg.sender),
            isim: isim,
            mulkTipi: mulkTipi,
            mulkAdresi: mulkAdresi
        });
    }

    // Mülkü kiralamak için fonksiyon
    function mulkKirala(string memory mulkAdresi, uint256 baslangicTarihi, uint256 bitisTarihi) public {
        require(kiralamalar[mulkAdresi].kirada == false, "Bu mülk zaten kirada.");

        kiralamalar[mulkAdresi] = Kiralama({
            mulkTipi: mulkSahipleri[msg.sender].mulkTipi,
            mulkAdresi: mulkAdresi,
            kiraci: payable(msg.sender),
            baslangicTarihi: baslangicTarihi,
            bitisTarihi: bitisTarihi,
            kirada: true
        });
    }

    // Kiralama işlemini sonlandırmak için fonksiyon
    function kiralamaSonlandir(string memory mulkAdresi) public sadeceSahip(mulkAdresi) {
        require(kiralamalar[mulkAdresi].kirada == true, "Bu mülk kirada değil.");
        delete kiralamalar[mulkAdresi];
    }

    // Kiracının bir problemi bildirmesi için fonksiyon
    function sorunBildir(string memory mulkAdresi, string memory sorun) public {
        require(kiralamalar[mulkAdresi].kirada == true, "Bu mülk kirada değil.");
        require(kiralamalar[mulkAdresi].kiraci == msg.sender, "Bu işlemi sadece kiracı yapabilir.");

        // Sorunun bildirildiğine dair bir olay tetikleniyor.
        emit SorunBildirildi(mulkAdresi, sorun);
    }

    event SorunBildirildi(string mulkAdresi, string sorun);
}
