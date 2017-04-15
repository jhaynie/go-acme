package types

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"

	logger "github.com/jtblin/go-logger"
	"github.com/xenolf/lego/acme"
)

// Account is used to store lets encrypt registration info
// and implements the acme.User interface.
type Account struct {
	Email              string
	DomainsCertificate *DomainCertificate
	PrivateKey         []byte
	Registration       *acme.RegistrationResource
}

// GetEmail returns email.
func (a Account) GetEmail() string {
	return a.Email
}

// GetRegistration returns lets encrypt registration resource.
func (a Account) GetRegistration() *acme.RegistrationResource {
	return a.Registration
}

// GetPrivateKey returns private key.
func (a Account) GetPrivateKey() crypto.PrivateKey {
	privateKey, err := x509.ParsePKCS1PrivateKey(a.PrivateKey)
	if err != nil {
		panic("invalid private key")
	}
	return privateKey
}

// NewAccount creates a new account for the specified email and domain.
func NewAccount(email string, domain *Domain, logger logger.Interface) (*Account, error) {
	// Create a user. New accounts need an email and private key to start
	privateKey, err := rsa.GenerateKey(rand.Reader, 4096)
	if err != nil {
		return nil, err
	}
	account := &Account{
		Email:      email,
		PrivateKey: x509.MarshalPKCS1PrivateKey(privateKey),
	}
	account.DomainsCertificate = &DomainCertificate{
		Certificate: &Certificate{},
		Domain:      domain,
	}
	return account, nil
}
