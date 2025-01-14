import 'package:async/async.dart';
import 'package:seeds/datasource/local/cache_repository.dart';
import 'package:seeds/datasource/local/settings_storage.dart';
import 'package:seeds/datasource/remote/api/profile_repository.dart';
import 'package:seeds/datasource/remote/api/proposals_repository.dart';
import 'package:seeds/datasource/remote/api/voice_repository.dart';
import 'package:seeds/datasource/remote/model/proposal_model.dart';
import 'package:seeds/datasource/remote/model/vote_model.dart';

class GetProposalDataUseCase {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ProposalsRepository _proposalsRepository = ProposalsRepository();
  final VoiceRepository _voiceRepository = VoiceRepository();

  Future<List<Result>> run(ProposalModel proposal) {
    final userAccount = settingsStorage.accountName;
    final _getVoice = proposal.campaignType == 'alliance'
        ? _voiceRepository.getAllianceVoice(userAccount)
        : _voiceRepository.getCampaignVoice(userAccount);

    final futures = [
      _profileRepository.getProfile(proposal.creator),
      _fetchVote(proposal.id, userAccount),
      _getVoice,
    ];
    return Future.wait(futures);
  }

  Future<Result> _fetchVote(int proposalId, String account) async {
    final cacheRepository = const CacheRepository();
    VoteModel? voteModel = await cacheRepository.getProposalVote(account, proposalId);
    if (voteModel == null) {
      final result = await _proposalsRepository.getVote(proposalId, account);
      if (result.isValue) {
        voteModel = result.asValue!.value as VoteModel;
        if (voteModel.isVoted) {
          await cacheRepository.saveProposalVote(proposalId, voteModel);
        }
      }
    }
    return ValueResult(voteModel);
  }
}
