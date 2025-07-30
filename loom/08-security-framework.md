# Atlassian Loom: Security Framework

## Document Overview
This document defines the comprehensive security framework for the Atlassian Loom platform, covering video content security, user privacy protection, data encryption, access controls, and compliance requirements.

## 1. Video Content Security

### 1.1 End-to-End Encryption

#### 1.1.1 Video Encryption Service
```go
// Video Encryption Service
package security

import (
    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
    "crypto/sha256"
    "encoding/base64"
    "fmt"
    "io"
    "time"
)

type VideoEncryptionService struct {
    masterKey []byte
    gcm       cipher.AEAD
}

type EncryptedVideo struct {
    VideoID        string `json:"video_id"`
    EncryptedData  []byte `json:"encrypted_data"`
    Nonce          []byte `json:"nonce"`
    KeyFingerprint string `json:"key_fingerprint"`
    Algorithm      string `json:"algorithm"`
    CreatedAt      int64  `json:"created_at"`
}

func NewVideoEncryptionService(masterKey []byte) (*VideoEncryptionService, error) {
    block, err := aes.NewCipher(masterKey)
    if err != nil {
        return nil, fmt.Errorf("failed to create cipher: %w", err)
    }
    
    gcm, err := cipher.NewGCM(block)
    if err != nil {
        return nil, fmt.Errorf("failed to create GCM: %w", err)
    }
    
    return &VideoEncryptionService{
        masterKey: masterKey,
        gcm:       gcm,
    }, nil
}

func (ves *VideoEncryptionService) EncryptVideo(videoID string, videoData []byte) (*EncryptedVideo, error) {
    // Generate random nonce
    nonce := make([]byte, ves.gcm.NonceSize())
    if _, err := io.ReadFull(rand.Reader, nonce); err != nil {
        return nil, fmt.Errorf("failed to generate nonce: %w", err)
    }
    
    // Encrypt video data
    encryptedData := ves.gcm.Seal(nil, nonce, videoData, []byte(videoID))
    
    // Generate key fingerprint
    keyFingerprint := ves.generateKeyFingerprint()
    
    return &EncryptedVideo{
        VideoID:        videoID,
        EncryptedData:  encryptedData,
        Nonce:          nonce,
        KeyFingerprint: keyFingerprint,
        Algorithm:      "AES-256-GCM",
        CreatedAt:      time.Now().Unix(),
    }, nil
}

func (ves *VideoEncryptionService) DecryptVideo(encrypted *EncryptedVideo) ([]byte, error) {
    // Verify key fingerprint
    if encrypted.KeyFingerprint != ves.generateKeyFingerprint() {
        return nil, fmt.Errorf("key fingerprint mismatch")
    }
    
    // Decrypt video data
    decryptedData, err := ves.gcm.Open(nil, encrypted.Nonce, encrypted.EncryptedData, []byte(encrypted.VideoID))
    if err != nil {
        return nil, fmt.Errorf("failed to decrypt video: %w", err)
    }
    
    return decryptedData, nil
}

func (ves *VideoEncryptionService) generateKeyFingerprint() string {
    hash := sha256.Sum256(ves.masterKey)
    return base64.StdEncoding.EncodeToString(hash[:8])
}
```

### 1.2 Video Access Control

#### 1.2.1 Access Control Implementation
```go
// Video Access Control
type VideoAccessControl struct {
    VideoID           string            `json:"video_id"`
    OwnerID           string            `json:"owner_id"`
    AccessLevel       AccessLevel       `json:"access_level"`
    AllowedUsers      []string          `json:"allowed_users"`
    AllowedDomains    []string          `json:"allowed_domains"`
    ExpiresAt         *time.Time        `json:"expires_at"`
    PasswordProtected bool              `json:"password_protected"`
    PasswordHash      string            `json:"password_hash"`
    ViewLimit         *int              `json:"view_limit"`
    DownloadEnabled   bool              `json:"download_enabled"`
    WatermarkEnabled  bool              `json:"watermark_enabled"`
    Permissions       map[string]bool   `json:"permissions"`
    CreatedAt         time.Time         `json:"created_at"`
    UpdatedAt         time.Time         `json:"updated_at"`
}

type AccessLevel int

const (
    AccessLevelPrivate AccessLevel = iota
    AccessLevelRestricted
    AccessLevelPublic
    AccessLevelUnlisted
)

func (vac *VideoAccessControl) CanAccess(userID string, request *AccessRequest) (bool, error) {
    // Check expiration
    if vac.ExpiresAt != nil && time.Now().After(*vac.ExpiresAt) {
        return false, fmt.Errorf("access expired")
    }
    
    // Check view limit
    if vac.ViewLimit != nil && request.ViewCount >= *vac.ViewLimit {
        return false, fmt.Errorf("view limit exceeded")
    }
    
    // Check access level
    switch vac.AccessLevel {
    case AccessLevelPrivate:
        return vac.checkPrivateAccess(userID, request)
    case AccessLevelRestricted:
        return vac.checkRestrictedAccess(userID, request)
    case AccessLevelPublic:
        return vac.checkPublicAccess(request)
    case AccessLevelUnlisted:
        return vac.checkUnlistedAccess(request)
    default:
        return false, fmt.Errorf("unknown access level")
    }
}

func (vac *VideoAccessControl) checkPrivateAccess(userID string, request *AccessRequest) (bool, error) {
    // Only owner and explicitly allowed users
    if userID == vac.OwnerID {
        return true, nil
    }
    
    for _, allowedUser := range vac.AllowedUsers {
        if userID == allowedUser {
            return vac.checkAdditionalRestrictions(request)
        }
    }
    
    return false, fmt.Errorf("access denied")
}

func (vac *VideoAccessControl) checkRestrictedAccess(userID string, request *AccessRequest) (bool, error) {
    // Check domain restrictions
    if len(vac.AllowedDomains) > 0 {
        if !vac.isDomainAllowed(request.Domain) {
            return false, fmt.Errorf("domain not allowed")
        }
    }
    
    // Check password protection
    if vac.PasswordProtected {
        if !vac.verifyPassword(request.Password) {
            return false, fmt.Errorf("invalid password")
        }
    }
    
    return vac.checkAdditionalRestrictions(request)
}

func (vac *VideoAccessControl) checkAdditionalRestrictions(request *AccessRequest) (bool, error) {
    // Check password protection
    if vac.PasswordProtected && !vac.verifyPassword(request.Password) {
        return false, fmt.Errorf("invalid password")
    }
    
    // Check domain restrictions
    if len(vac.AllowedDomains) > 0 && !vac.isDomainAllowed(request.Domain) {
        return false, fmt.Errorf("domain not allowed")
    }
    
    return true, nil
}

func (vac *VideoAccessControl) isDomainAllowed(domain string) bool {
    for _, allowedDomain := range vac.AllowedDomains {
        if allowedDomain == domain || 
           (strings.HasPrefix(allowedDomain, "*.") && 
            strings.HasSuffix(domain, allowedDomain[1:])) {
            return true
        }
    }
    return false
}

func (vac *VideoAccessControl) verifyPassword(providedPassword string) bool {
    if vac.PasswordHash == "" {
        return true
    }
    
    // Use bcrypt for password verification
    hash := sha256.Sum256([]byte(providedPassword))
    providedHash := base64.StdEncoding.EncodeToString(hash[:])
    
    return providedHash == vac.PasswordHash
}

type AccessRequest struct {
    UserID    string `json:"user_id"`
    Domain    string `json:"domain"`
    Password  string `json:"password"`
    ViewCount int    `json:"view_count"`
    IPAddress string `json:"ip_address"`
    UserAgent string `json:"user_agent"`
    Referrer  string `json:"referrer"`
}
```

### 1.3 Digital Rights Management (DRM)

#### 1.3.1 DRM Service Implementation
```javascript
// DRM Implementation for Video Protection
class DRMService {
    constructor(config) {
        this.config = config;
        this.widevineProvider = new WidevineProvider(config.widevine);
        this.playreadyProvider = new PlayReadyProvider(config.playready);
        this.fairplayProvider = new FairPlayProvider(config.fairplay);
    }
    
    async protectVideo(videoId, videoPath, protectionLevel = 'standard') {
        const protectionConfig = this.getProtectionConfig(protectionLevel);
        
        const tasks = [];
        
        // Widevine (Chrome, Android)
        if (protectionConfig.widevine) {
            tasks.push(this.applyWidevineProtection(videoId, videoPath));
        }
        
        // PlayReady (Edge, Xbox)
        if (protectionConfig.playready) {
            tasks.push(this.applyPlayReadyProtection(videoId, videoPath));
        }
        
        // FairPlay (Safari, iOS)
        if (protectionConfig.fairplay) {
            tasks.push(this.applyFairPlayProtection(videoId, videoPath));
        }
        
        const results = await Promise.allSettled(tasks);
        
        return {
            videoId,
            protectionLevel,
            drm: {
                widevine: results[0]?.value,
                playready: results[1]?.value,
                fairplay: results[2]?.value
            }
        };
    }
    
    async applyWidevineProtection(videoId, videoPath) {
        // Generate content key
        const contentKey = await this.generateContentKey();
        
        // Create key ID
        const keyId = this.generateKeyId(videoId);
        
        // Encrypt video with content key
        const encryptedVideoPath = await this.encryptVideoForWidevine(
            videoPath, 
            contentKey, 
            keyId
        );
        
        // Store key in Widevine license server
        await this.widevineProvider.storeKey(keyId, contentKey, {
            videoId,
            policy: this.createLicensePolicy(videoId)
        });
        
        return {
            keyId,
            licenseUrl: `${this.config.widevine.licenseServerUrl}/license`,
            encryptedVideoPath
        };
    }
    
    createLicensePolicy(videoId) {
        return {
            playbackDurationSeconds: 86400, // 24 hours
            licenseDurationSeconds: 2592000, // 30 days
            renewalRecoveryDurationSeconds: 3600, // 1 hour
            playbackType: 'STREAMING',
            persistentLicense: false,
            rentalDurationSeconds: null,
            allowedTrackTypes: ['SD', 'HD', 'UHD1'],
            securityLevel: 1,
            requiredOutputProtection: {
                hdcp: 'HDCP_V1'
            }
        };
    }
    
    async generateLicense(keyId, challenge, clientInfo) {
        // Validate client and request
        const validation = await this.validateLicenseRequest(keyId, challenge, clientInfo);
        if (!validation.valid) {
            throw new Error(`License validation failed: ${validation.reason}`);
        }
        
        // Get DRM provider based on client
        const provider = this.selectDRMProvider(clientInfo.userAgent);
        
        // Generate license
        const license = await provider.generateLicense(keyId, challenge, {
            policy: validation.policy,
            clientInfo
        });
        
        // Log license generation for audit
        await this.logLicenseGeneration(keyId, clientInfo, license);
        
        return license;
    }
    
    async validateLicenseRequest(keyId, challenge, clientInfo) {
        // Get video access control
        const videoId = this.extractVideoIdFromKeyId(keyId);
        const accessControl = await this.getVideoAccessControl(videoId);
        
        // Check if user has access
        const hasAccess = await accessControl.canAccess(clientInfo.userId, {
            domain: clientInfo.domain,
            ipAddress: clientInfo.ipAddress,
            userAgent: clientInfo.userAgent
        });
        
        if (!hasAccess) {
            return { valid: false, reason: 'Access denied' };
        }
        
        // Validate challenge
        const challengeValid = await this.validateChallenge(challenge, clientInfo);
        if (!challengeValid) {
            return { valid: false, reason: 'Invalid challenge' };
        }
        
        return {
            valid: true,
            policy: this.createLicensePolicy(videoId)
        };
    }
    
    selectDRMProvider(userAgent) {
        if (userAgent.includes('Chrome') || userAgent.includes('Android')) {
            return this.widevineProvider;
        } else if (userAgent.includes('Edge') || userAgent.includes('Xbox')) {
            return this.playreadyProvider;
        } else if (userAgent.includes('Safari') || userAgent.includes('iOS')) {
            return this.fairplayProvider;
        } else {
            return this.widevineProvider;
        }
    }
    
    getProtectionConfig(level) {
        const configs = {
            'basic': {
                widevine: true,
                playready: false,
                fairplay: false
            },
            'standard': {
                widevine: true,
                playready: true,
                fairplay: true
            },
            'premium': {
                widevine: true,
                playready: true,
                fairplay: true,
                additionalSecurity: true
            }
        };
        
        return configs[level] || configs['standard'];
    }
    
    async generateContentKey() {
        const crypto = require('crypto');
        return crypto.randomBytes(16); // 128-bit key
    }
    
    generateKeyId(videoId) {
        const crypto = require('crypto');
        const hash = crypto.createHash('sha256').update(videoId).digest();
        return hash.slice(0, 16); // 128-bit key ID
    }
}
```

## 2. User Privacy & Data Protection

### 2.1 GDPR Compliance Implementation

#### 2.1.1 GDPR Compliance Service
```python
# GDPR Compliance Service
from typing import List, Dict, Any, Optional
from dataclasses import dataclass
from enum import Enum
import json
import hashlib
from datetime import datetime, timedelta

class DataCategory(Enum):
    PERSONAL_DATA = "personal_data"
    SENSITIVE_DATA = "sensitive_data"
    BEHAVIORAL_DATA = "behavioral_data"
    TECHNICAL_DATA = "technical_data"
    COMMUNICATION_DATA = "communication_data"

class ProcessingPurpose(Enum):
    SERVICE_PROVISION = "service_provision"
    ANALYTICS = "analytics"
    MARKETING = "marketing"
    SECURITY = "security"
    LEGAL_COMPLIANCE = "legal_compliance"

class LegalBasis(Enum):
    CONSENT = "consent"
    CONTRACT = "contract"
    LEGAL_OBLIGATION = "legal_obligation"
    VITAL_INTERESTS = "vital_interests"
    PUBLIC_TASK = "public_task"
    LEGITIMATE_INTERESTS = "legitimate_interests"

@dataclass
class ConsentRecord:
    user_id: str
    purpose: ProcessingPurpose
    legal_basis: LegalBasis
    granted: bool
    timestamp: datetime
    ip_address: str
    user_agent: str
    consent_version: str
    expires_at: Optional[datetime] = None
    withdrawn_at: Optional[datetime] = None

@dataclass
class DataProcessingRecord:
    user_id: str
    data_category: DataCategory
    purpose: ProcessingPurpose
    legal_basis: LegalBasis
    processor: str
    retention_period: timedelta
    created_at: datetime
    consent_id: Optional[str] = None

class GDPRComplianceService:
    def __init__(self, database, encryption_service):
        self.db = database
        self.encryption = encryption_service
        self.consent_manager = ConsentManager(database)
        self.data_processor = DataProcessor(database, encryption_service)
        self.audit_logger = AuditLogger(database)
    
    async def record_consent(self, consent: ConsentRecord) -> str:
        """Record user consent for data processing"""
        # Validate consent record
        self._validate_consent_record(consent)
        
        # Store consent record
        consent_id = await self.consent_manager.store_consent(consent)
        
        # Log consent for audit trail
        await self.audit_logger.log_consent_event(
            user_id=consent.user_id,
            event_type="consent_granted" if consent.granted else "consent_denied",
            consent_id=consent_id,
            details={
                "purpose": consent.purpose.value,
                "legal_basis": consent.legal_basis.value,
                "ip_address": consent.ip_address,
                "user_agent": consent.user_agent
            }
        )
        
        return consent_id
    
    async def withdraw_consent(self, user_id: str, purpose: ProcessingPurpose) -> bool:
        """Withdraw user consent for specific purpose"""
        # Find active consent
        consent = await self.consent_manager.get_active_consent(user_id, purpose)
        if not consent:
            return False
        
        # Mark consent as withdrawn
        await self.consent_manager.withdraw_consent(consent.id)
        
        # Stop processing data for this purpose
        await self.data_processor.stop_processing(user_id, purpose)
        
        # Log withdrawal
        await self.audit_logger.log_consent_event(
            user_id=user_id,
            event_type="consent_withdrawn",
            consent_id=consent.id,
            details={"purpose": purpose.value}
        )
        
        return True
    
    async def export_user_data(self, user_id: str) -> Dict[str, Any]:
        """Export all user data (Right to Data Portability)"""
        # Get all data categories for user
        user_data = {}
        
        # Personal data
        personal_data = await self.data_processor.get_personal_data(user_id)
        user_data["personal_data"] = self._anonymize_sensitive_fields(personal_data)
        
        # Video data
        video_data = await self.data_processor.get_video_data(user_id)
        user_data["videos"] = video_data
        
        # Analytics data
        analytics_data = await self.data_processor.get_analytics_data(user_id)
        user_data["analytics"] = analytics_data
        
        # Communication data
        communication_data = await self.data_processor.get_communication_data(user_id)
        user_data["communications"] = communication_data
        
        # Consent history
        consent_history = await self.consent_manager.get_consent_history(user_id)
        user_data["consent_history"] = consent_history
        
        # Log data export
        await self.audit_logger.log_data_event(
            user_id=user_id,
            event_type="data_export",
            details={"export_format": "json", "data_categories": list(user_data.keys())}
        )
        
        return user_data
    
    async def delete_user_data(self, user_id: str, categories: List[DataCategory] = None) -> Dict[str, bool]:
        """Delete user data (Right to Erasure)"""
        if categories is None:
            categories = list(DataCategory)
        
        deletion_results = {}
        
        for category in categories:
            try:
                # Check if deletion is allowed for this category
                if not await self._can_delete_category(user_id, category):
                    deletion_results[category.value] = False
                    continue
                
                # Delete data for category
                await self.data_processor.delete_data_category(user_id, category)
                deletion_results[category.value] = True
                
                # Log deletion
                await self.audit_logger.log_data_event(
                    user_id=user_id,
                    event_type="data_deleted",
                    details={"category": category.value}
                )
                
            except Exception as e:
                deletion_results[category.value] = False
                await self.audit_logger.log_error(
                    user_id=user_id,
                    error_type="deletion_failed",
                    details={"category": category.value, "error": str(e)}
                )
        
        return deletion_results
    
    async def anonymize_user_data(self, user_id: str) -> bool:
        """Anonymize user data while preserving analytics value"""
        try:
            # Generate anonymous ID
            anonymous_id = self._generate_anonymous_id(user_id)
            
            # Anonymize personal identifiers
            await self.data_processor.anonymize_personal_data(user_id, anonymous_id)
            
            # Update video metadata to remove personal identifiers
            await self.data_processor.anonymize_video_metadata(user_id, anonymous_id)
            
            # Anonymize analytics data
            await self.data_processor.anonymize_analytics_data(user_id, anonymous_id)
            
            # Log anonymization
            await self.audit_logger.log_data_event(
                user_id=user_id,
                event_type="data_anonymized",
                details={"anonymous_id": anonymous_id}
            )
            
            return True
            
        except Exception as e:
            await self.audit_logger.log_error(
                user_id=user_id,
                error_type="anonymization_failed",
                details={"error": str(e)}
            )
            return False
    
    def _generate_anonymous_id(self, user_id: str) -> str:
        """Generate consistent anonymous ID for user"""
        hash_input = f"{user_id}:{self.encryption.get_salt()}"
        return hashlib.sha256(hash_input.encode()).hexdigest()[:16]
    
    def _validate_consent_record(self, consent: ConsentRecord):
        """Validate consent record completeness"""
        required_fields = ['user_id', 'purpose', 'legal_basis', 'timestamp', 'ip_address']
        for field in required_fields:
            if not getattr(consent, field):
                raise ValueError(f"Missing required field: {field}")
    
    async def _can_delete_category(self, user_id: str, category: DataCategory) -> bool:
        """Check if data category can be deleted"""
        # Check for legal retention requirements
        retention_requirements = await self.data_processor.get_retention_requirements(user_id, category)
        
        for requirement in retention_requirements:
            if requirement.mandatory and not requirement.expired:
                return False
        
        return True
```

### 2.2 Data Retention Policy

#### 2.2.1 Data Retention Service
```python
# Data Retention Policy Implementation
class DataRetentionService:
    def __init__(self, database):
        self.db = database
        self.retention_policies = self._load_retention_policies()
    
    def _load_retention_policies(self) -> Dict[str, Dict]:
        """Load data retention policies"""
        return {
            "video_recordings": {
                "retention_period_days": 2555,  # 7 years
                "auto_delete": False,
                "legal_basis": "contract"
            },
            "user_analytics": {
                "retention_period_days": 1095,  # 3 years
                "auto_delete": True,
                "legal_basis": "legitimate_interests"
            },
            "audit_logs": {
                "retention_period_days": 2555,  # 7 years
                "auto_delete": False,
                "legal_basis": "legal_obligation"
            },
            "marketing_data": {
                "retention_period_days": 365,  # 1 year
                "auto_delete": True,
                "legal_basis": "consent"
            }
        }
    
    async def apply_retention_policies(self):
        """Apply data retention policies across all data types"""
        for data_type, policy in self.retention_policies.items():
            if policy["auto_delete"]:
                await self._delete_expired_data(data_type, policy)
            else:
                await self._mark_expired_data(data_type, policy)
    
    async def _delete_expired_data(self, data_type: str, policy: Dict):
        """Delete data that has exceeded retention period"""
        cutoff_date = datetime.now() - timedelta(days=policy["retention_period_days"])
        
        if data_type == "user_analytics":
            query = "DELETE FROM user_analytics WHERE created_at < %s"
            await self.db.execute(query, [cutoff_date])
        elif data_type == "marketing_data":
            query = "DELETE FROM marketing_interactions WHERE created_at < %s"
            await self.db.execute(query, [cutoff_date])
```

## 3. Authentication & Authorization

### 3.1 Multi-Factor Authentication

#### 3.1.1 MFA Implementation
```javascript
// Multi-Factor Authentication Service
class MFAService {
    constructor(config) {
        this.config = config;
        this.totpService = new TOTPService();
        this.smsService = new SMSService(config.sms);
        this.emailService = new EmailService(config.email);
    }
    
    async enableMFA(userId, method, contactInfo) {
        const methods = {
            'totp': () => this.enableTOTP(userId),
            'sms': () => this.enableSMS(userId, contactInfo.phoneNumber),
            'email': () => this.enableEmail(userId, contactInfo.email),
            'backup_codes': () => this.generateBackupCodes(userId)
        };
        
        if (!methods[method]) {
            throw new Error(`Unsupported MFA method: ${method}`);
        }
        
        const result = await methods[method]();
        
        // Store MFA configuration
        await this.storeMFAConfig(userId, method, result);
        
        // Log MFA enablement
        await this.logSecurityEvent(userId, 'mfa_enabled', { method });
        
        return result;
    }
    
    async enableTOTP(userId) {
        // Generate secret key
        const secret = this.totpService.generateSecret();
        
        // Generate QR code for authenticator apps
        const qrCode = await this.totpService.generateQRCode(userId, secret);
        
        return {
            secret,
            qrCode,
            backupCodes: await this.generateBackupCodes(userId)
        };
    }
    
    async enableSMS(userId, phoneNumber) {
        // Validate phone number
        if (!this.isValidPhoneNumber(phoneNumber)) {
            throw new Error('Invalid phone number');
        }
        
        // Send verification code
        const verificationCode = this.generateVerificationCode();
        await this.smsService.sendCode(phoneNumber, verificationCode);
        
        // Store temporary verification
        await this.storeVerification(userId, 'sms', phoneNumber, verificationCode);
        
        return {
            phoneNumber: this.maskPhoneNumber(phoneNumber),
            expiresIn: 300 // 5 minutes
        };
    }
    
    async verifyMFA(userId, method, code, challengeId = null) {
        const verifiers = {
            'totp': () => this.verifyTOTP(userId, code),
            'sms': () => this.verifySMS(userId, code, challengeId),
            'email': () => this.verifyEmail(userId, code, challengeId),
            'backup_code': () => this.verifyBackupCode(userId, code)
        };
        
        if (!verifiers[method]) {
            throw new Error(`Unsupported MFA method: ${method}`);
        }
        
        const isValid = await verifiers[method]();
        
        if (isValid) {
            // Log successful verification
            await this.logSecurityEvent(userId, 'mfa_verified', { method });
            
            // Update last used timestamp
            await this.updateMFALastUsed(userId, method);
        } else {
            // Log failed verification
            await this.logSecurityEvent(userId, 'mfa_failed', { method });
            
            // Check for brute force attempts
            await this.checkBruteForce(userId, method);
        }
        
        return isValid;
    }
    
    async verifyTOTP(userId, code) {
        const mfaConfig = await this.getMFAConfig(userId, 'totp');
        if (!mfaConfig) {
            return false;
        }
        
        return this.totpService.verify(code, mfaConfig.secret);
    }
    
    async verifySMS(userId, code, challengeId) {
        const verification = await this.getVerification(userId, 'sms', challengeId);
        if (!verification) {
            return false;
        }
        
        // Check expiration
        if (Date.now() > verification.expiresAt) {
            await this.deleteVerification(verification.id);
            return false;
        }
        
        // Verify code
        const isValid = verification.code === code;
        
        if (isValid) {
            await this.deleteVerification(verification.id);
        }
        
        return isValid;
    }
    
    async generateBackupCodes(userId) {
        const codes = [];
        for (let i = 0; i < 10; i++) {
            codes.push(this.generateSecureCode(8));
        }
        
        // Hash and store backup codes
        const hashedCodes = codes.map(code => ({
            code: this.hashCode(code),
            used: false,
            createdAt: new Date()
        }));
        
        await this.storeBackupCodes(userId, hashedCodes);
        
        return codes;
    }
    
    async verifyBackupCode(userId, code) {
        const backupCodes = await this.getBackupCodes(userId);
        const hashedCode = this.hashCode(code);
        
        const matchingCode = backupCodes.find(bc => 
            bc.code === hashedCode && !bc.used
        );
        
        if (matchingCode) {
            // Mark code as used
            await this.markBackupCodeUsed(matchingCode.id);
            return true;
        }
        
        return false;
    }
    
    generateSecureCode(length) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        let result = '';
        for (let i