public class UpdateFileRelatedQueueable implements Queueable, Database.AllowsCallouts {
    private Id evaluationId;
    private Id recordId;

    public UpdateFileRelatedQueueable(Id evaluationId, Id recordId) {
        this.evaluationId = evaluationId;
        this.recordId = recordId;
    }

    public void execute(QueueableContext context) {
        System.debug('Queueable execution started. Evaluation ID: ' + evaluationId + ', Record ID: ' + recordId);

        // 1. 기존 파일 가져오기
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        if (recordId != null) {
            cdlList = [
                SELECT Id, ContentDocumentId, LinkedEntityId 
                FROM ContentDocumentLink 
                WHERE LinkedEntityId = :recordId
                AND ContentDocument.CreatedDate = TODAY
            ];
        }

        // 2. 기존 파일 삭제
        if (!cdlList.isEmpty()) {
            delete cdlList;
            System.debug('Existing ContentDocumentLinks deleted.');
        }

        // 3. 새로운 파일 복사 및 링크 생성
        if (!cdlList.isEmpty()) {
            List<ContentDocumentLink> newCdlList = new List<ContentDocumentLink>();
            for (ContentDocumentLink cdl : cdlList) {
                ContentDocumentLink newCdl = new ContentDocumentLink();
                newCdl.ContentDocumentId = cdl.ContentDocumentId;
                newCdl.LinkedEntityId = evaluationId;
                newCdl.ShareType = 'V';
                newCdl.Visibility = 'AllUsers';
                newCdlList.add(newCdl);
            }

            if (!newCdlList.isEmpty()) {
                insert newCdlList; // 새로운 링크 한 번에 삽입
                System.debug('New ContentDocumentLinks created for Evaluation ID: ' + evaluationId);
            }
        } else {
            System.debug('No files found to link to the new Evaluation ID.');
        }

        System.debug('Queueable execution completed.');
    }
}