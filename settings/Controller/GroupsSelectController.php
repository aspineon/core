<?php
/**
 * @author Sujith Haridasan "sharidasan@owncloud.com"
 *
 * @copyright Copyright (c) 2018, ownCloud GmbH
 * @license AGPL-3.0
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 */

namespace OC\Settings\Controller;

use OC\MetaData;
use OCP\AppFramework\Controller;
use OCP\AppFramework\Http\DataResponse;
use OCP\IGroupManager;
use OCP\IL10N;
use OCP\IRequest;
use OCP\IUserSession;

class GroupsSelectController extends Controller {
	/** @var IGroupManager */
	private $groupManager;
	/** @var IL10N */
	private $l10n;
	/** @var IUserSession */
	private $userSession;

	/**
	 * @param string $appName
	 * @param IRequest $request
	 * @param IGroupManager $groupManager
	 * @param IUserSession $userSession
	 * @param IL10N $l10n
	 */
	public function __construct($appName,
								IRequest $request,
								IGroupManager $groupManager,
								IUserSession $userSession,
								IL10N $l10n) {
		parent::__construct($appName, $request);
		$this->groupManager = $groupManager;
		$this->userSession = $userSession;
		$this->l10n = $l10n;
	}

	/**
	 * @NoAdminRequired
	 *
	 * @param string $pattern
	 * @param bool $filterGroups
	 * @param int $sortGroups
	 * @return DataResponse
	 */
	public function index($pattern = '', $filterGroups = false, $sortGroups = MetaData::SORT_USERCOUNT) {
		$groupPattern = $filterGroups ? $pattern : '';

		$groupsInfo = new MetaData(
			$this->userSession->getUser()->getUID(),
			$this->isAdmin(),
			$this->groupManager,
			$this->userSession
		);
		$groupsInfo->setSorting($sortGroups);
		list($adminGroups, $groups) = $groupsInfo->get($groupPattern, $pattern);

		return new DataResponse(
			[
				'data' => ['adminGroups' => $adminGroups, 'groups' => $groups]
			]
		);
	}

	/**
	 * Check if current user (active and not in incognito mode)
	 * is an admin
	 *
	 * @return bool
	 */
	private function isAdmin() {
		// Get current user (active and not in incognito mode)
		$user = $this->userSession->getUser();
		if ($user !== null) {
			return $this->groupManager->isAdmin($user->getUID());
		}
		return false;
	}
}